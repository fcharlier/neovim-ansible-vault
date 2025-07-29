-- ansible-vault.lua - Neovim ansible-vault plugin core functionality

local M = {}

-- Debug mode toggle
M.debug_mode = false

-- Debug logging function
local function debug_log(message)
  if M.debug_mode then
    local log_file = vim.fn.expand('~/.config/nvim/ansible-vault-debug.log')
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local log_entry = '[' .. timestamp .. '] ' .. message .. '\n'

    -- Write to file
    local file = io.open(log_file, 'a')
    if file then
      file:write(log_entry)
      file:close()
    end

    -- Also show in echo (but won't persist)
    vim.api.nvim_echo({{message, 'Comment'}}, false, {})
  end
end

-- Get configuration values from Vim
local function get_config()
  return {
    password_file = vim.g.ansible_vault_password_file or '',
    identity = vim.g.ansible_vault_identity or ''
  }
end

-- Build ansible-vault command with options
local function build_vault_command(operation, extra_args)
  local config = get_config()
  local cmd = 'ansible-vault ' .. operation

  if config.password_file ~= '' then
    cmd = cmd .. ' --vault-password-file=' .. config.password_file
  end

  if config.identity ~= '' then
    cmd = cmd .. ' --vault-id=' .. config.identity

    -- For encrypt operations, also specify which vault-id to use for encryption
    if operation == 'encrypt' then
      -- Extract just the vault ID name (before @ if present)
      local vault_id_name = config.identity:match('^([^@]+)')
      if vault_id_name then
        cmd = cmd .. ' --encrypt-vault-id=' .. vault_id_name
      else
        cmd = cmd .. ' --encrypt-vault-id=' .. config.identity
      end
    end
  else
    -- If no identity configured, use default for encrypt operations
    if operation == 'encrypt' then
      cmd = cmd .. ' --encrypt-vault-id=default'
    end
  end

  if extra_args then
    cmd = cmd .. ' ' .. extra_args
  end

  return cmd
end

-- Execute ansible-vault command with input
local function execute_vault_command(operation, input, extra_args)
  local temp_input = vim.fn.tempname()
  local temp_output = vim.fn.tempname()

  -- Write input to temporary file
  local input_file = io.open(temp_input, 'w')
  if not input_file then
    vim.api.nvim_err_writeln('Error: Could not create temporary input file')
    return nil
  end
  input_file:write(input)
  input_file:close()

  -- Build command
  local vault_cmd = build_vault_command(operation, extra_args)
  local full_command = string.format('%s < %s > %s 2>&1', vault_cmd, temp_input, temp_output)

  -- Execute command
  local exit_code = os.execute(full_command)

  -- Read output
  local output_file = io.open(temp_output, 'r')
  local output = ''
  if output_file then
    output = output_file:read('*all')
    output_file:close()
  end

  -- Clean up temporary files
  os.remove(temp_input)
  os.remove(temp_output)

  -- Check if command succeeded
  if exit_code ~= 0 and exit_code ~= true then
    local error_msg = 'ansible-vault ' .. operation .. ' failed\nOutput: ' .. output
    vim.api.nvim_err_writeln(error_msg)
    -- Also echo the error with a longer display time
    vim.api.nvim_echo({
      {'ansible-vault ' .. operation .. ' failed!', 'ErrorMsg'},
      {'\nOutput: ' .. output, 'ErrorMsg'}
    }, true, {})
    return nil
  end

  -- Remove trailing newline if present
  output = output:gsub('\n$', '')

  return output
end

-- Execute ansible-vault encrypt_string command (for value-only encryption)
local function execute_vault_encrypt_string(input, extra_args)
  local config = get_config()
  local vault_cmd = 'ansible-vault encrypt_string'

  if config.password_file ~= '' then
    vault_cmd = vault_cmd .. ' --vault-password-file=' .. config.password_file
  end

  if config.identity ~= '' then
    vault_cmd = vault_cmd .. ' --vault-id=' .. config.identity

    -- Extract just the vault ID name (before @ if present)
    local vault_id_name = config.identity:match('^([^@]+)')
    if vault_id_name then
      vault_cmd = vault_cmd .. ' --encrypt-vault-id=' .. vault_id_name
    else
      vault_cmd = vault_cmd .. ' --encrypt-vault-id=' .. config.identity
    end
  else
    vault_cmd = vault_cmd .. ' --encrypt-vault-id=default'
  end

  if extra_args then
    vault_cmd = vault_cmd .. ' ' .. extra_args
  end

  -- Use stdin for the string to encrypt
  vault_cmd = vault_cmd .. ' --stdin-name="value"'

  local temp_input = vim.fn.tempname()
  local temp_output = vim.fn.tempname()

  -- Write input to temporary file
  local input_file = io.open(temp_input, 'w')
  if not input_file then
    vim.api.nvim_err_writeln('Error: Could not create temporary input file')
    return nil
  end
  input_file:write(input)
  input_file:close()

  local full_command = string.format('%s < %s > %s 2>&1', vault_cmd, temp_input, temp_output)

  -- Execute command
  local exit_code = os.execute(full_command)

  -- Read output
  local output_file = io.open(temp_output, 'r')
  local output = ''
  if output_file then
    output = output_file:read('*all')
    output_file:close()
  end

  -- Clean up temporary files
  os.remove(temp_input)
  os.remove(temp_output)

    -- Check if command succeeded
  if exit_code ~= 0 and exit_code ~= true then
    local error_msg = 'ansible-vault encrypt_string failed\nOutput: ' .. output
    vim.api.nvim_err_writeln(error_msg)
    vim.api.nvim_echo({
      {'ansible-vault encrypt_string failed!', 'ErrorMsg'},
      {'\nOutput: ' .. output, 'ErrorMsg'}
    }, true, {})
    return nil
  end

  -- Remove trailing newline if present
  output = output:gsub('\n$', '')

  -- Clean up encrypt_string output format
  -- Remove "value: " prefix and surrounding quotes
  if output:match('^value:%s*!vault%s*|') then
    -- Remove "value: " prefix
    output = output:gsub('^value:%s*', '')
  elseif output:match('^"?value:%s*!vault%s*|') then
    -- Remove quotes and "value: " prefix
    output = output:gsub('^"?value:%s*', ''):gsub('"$', '')
  end

  return output
end

-- Execute ansible-vault command on a file
local function execute_vault_file_command(operation, filepath, extra_args)
  local vault_cmd = build_vault_command(operation, extra_args)
  local full_command = vault_cmd .. ' ' .. filepath

  local handle = io.popen(full_command .. ' 2>&1')
  local output = handle:read('*all')
  local success, _, exit_code = handle:close()

  if not success or exit_code ~= 0 then
    vim.api.nvim_err_writeln('ansible-vault ' .. operation .. ' failed on file: ' .. filepath)
    vim.api.nvim_err_writeln('Output: ' .. output)
    return false
  end

  return true
end

-- Get visual selection content
local function get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local start_col = start_pos[3]
  local end_line = end_pos[2]
  local end_col = end_pos[3]

  -- Debug info
  local debug_msg = string.format('Visual selection: lines %d-%d, cols %d-%d',
                                  start_line, end_line, start_col, end_col)

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if #lines == 0 then
    if M.debug_mode then
      vim.api.nvim_echo({{'Debug: No lines in selection', 'WarningMsg'}}, false, {})
    end
    return ''
  end

  local content
  -- Handle single line selection
  if #lines == 1 then
    content = lines[1]:sub(start_col, end_col)
  else
    -- Handle multi-line selection
    lines[1] = lines[1]:sub(start_col)
    lines[#lines] = lines[#lines]:sub(1, end_col)
    content = table.concat(lines, '\n')
  end

  -- Debug: show first few characters of selection
  if M.debug_mode then
    local preview = content:sub(1, 50):gsub('\n', '\\n')
    vim.api.nvim_echo({
      {'Debug: Selected content preview: "' .. preview .. '"', 'Comment'}
    }, false, {})
  end

  return content
end

-- Replace text in a range with new content
local function replace_range(start_line, end_line, new_content)
  local lines = vim.split(new_content, '\n')
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
end

-- Get content from line range
local function get_range_content(line1, line2)
  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
  return table.concat(lines, '\n')
end

-- Check if content is ansible-vault encrypted
local function is_vault_encrypted(content)
  if M.debug_mode then
    local preview = content:sub(1, 50):gsub('\n', '\\n')
    debug_log('is_vault_encrypted: checking "' .. preview .. '..."')
  end

  -- Trim leading whitespace for vault content check
  local trimmed_content = content:match('^%s*(.*)')

  -- Check for traditional $ANSIBLE_VAULT format (with or without leading whitespace)
  if trimmed_content:match('^%$ANSIBLE_VAULT') then
    if M.debug_mode then
      debug_log('Found traditional $ANSIBLE_VAULT format')
    end
    return true
  end

  -- Check for !vault format (multi-line)
  if content:match('!vault%s*|') and content:match('%$ANSIBLE_VAULT') then
    if M.debug_mode then
      debug_log('Found !vault multi-line format')
    end
    return true
  end

  if M.debug_mode then
    debug_log('Content is NOT vault encrypted')
    debug_log('  Trimmed content starts with: "' .. trimmed_content:sub(1, 20) .. '"')
  end
  return false
end

-- Check if content looks like plain text (not encrypted)
local function is_plain_text(content)
  return not is_vault_encrypted(content)
end

-- Parse YAML key-value line and extract components
local function parse_yaml_line(content)
  -- Handle multi-line content (like !vault format)
  local lines = vim.split(content, '\n')
  local first_line = lines[1]

    -- Check for multi-line format (both !vault and regular YAML multi-line)
  local indent, key, rest = first_line:match('^(%s*)([%w_%-]+):%s*(.*)')
  if indent and key and rest then
    -- Check if this is a multi-line indicator
    local multiline_indicator = rest:match('^([|>])')
    local vault_indicator = rest:match('^(!vault%s*|)')

    if multiline_indicator or vault_indicator then
      local indicator = multiline_indicator or vault_indicator
      local suffix = rest:gsub('^[|>!vault%s]*|?%s*', '')

                    if M.debug_mode then
         debug_log('parse_yaml_line: Found multiline pattern')
         debug_log('  Indent: "' .. indent .. '"')
         debug_log('  Key: "' .. key .. '"')
         debug_log('  Indicator: "' .. indicator .. '"')
         debug_log('  Rest: "' .. rest .. '"')
         debug_log('  Suffix: "' .. suffix .. '"')
       end
    -- Extract the content from subsequent lines
    local content_lines = {}
    for i = 2, #lines do
      local line = lines[i]
      if line:match('^%s*$') then
        -- Keep empty lines as they might be significant in YAML
        table.insert(content_lines, '')
      elseif line:match('^%s') then
        -- Remove the base indentation to get the raw content
        local line_indent = line:match('^(%s*)')
        if #line_indent > #indent then
          -- This line is more indented, part of the multi-line content
          local expected_indent = string.rep(' ', #indent + 2)
          local content_line = line:match('^' .. expected_indent .. '(.*)$')
          if not content_line then
            -- Fallback: remove any leading whitespace
            content_line = line:match('^%s*(.*)')
          end

          if M.debug_mode then
            debug_log('  Line: "' .. line .. '"')
            debug_log('  Expected indent: "' .. expected_indent .. '" (length: ' .. #expected_indent .. ')')
            debug_log('  Line indent: "' .. line_indent .. '" (length: ' .. #line_indent .. ')')
            debug_log('  Extracted: "' .. (content_line or 'nil') .. '"')
          end

          table.insert(content_lines, content_line)
        else
          -- This line is at same or less indentation, end of multi-line block
          break
        end
      else
        -- Non-indented line, end of block
        break
      end
    end

    local extracted_content = table.concat(content_lines, '\n')

      -- Determine if this is a vault format
      local is_vault = vault_indicator ~= nil

      -- For vault content, strip ALL leading whitespace from each line
      if is_vault then
        local vault_lines = {}
        for _, line in ipairs(content_lines) do
          if line:match('^%s*$') then
            -- Keep empty lines
            table.insert(vault_lines, '')
          else
            -- Strip all leading whitespace for vault content
            local clean_line = line:match('^%s*(.*)')
            table.insert(vault_lines, clean_line)

            if M.debug_mode then
              debug_log('  Vault line cleaned: "' .. line .. '" -> "' .. clean_line .. '"')
            end
          end
        end
        extracted_content = table.concat(vault_lines, '\n')
      end

      return {
        indent = indent,
        key = key,
        value = extracted_content,
        suffix = suffix,
        original = content,
        is_vault_format = is_vault,
        multiline_indicator = indicator
      }
    end
  end

  -- Fall back to single-line patterns
  local patterns = {
    -- key: "quoted value"
    '^(%s*)([%w_%-]+):%s*"([^"]*)"(.*)$',
    -- key: 'quoted value'
    "^(%s*)([%w_%-]+):%s*'([^']*)'(.*)$",
    -- key: unquoted value
    '^(%s*)([%w_%-]+):%s*([^%s#][^#]*)(.*)$',
    -- key: value with inline comment
    '^(%s*)([%w_%-]+):%s*([^#]+)(#.*)$'
  }

  for _, pattern in ipairs(patterns) do
    local indent, key, value, suffix = first_line:match(pattern)
    if indent and key and value then
      -- Clean up value (trim whitespace)
      value = value:match('^%s*(.-)%s*$')
      suffix = suffix or ''
                    if M.debug_mode then
         debug_log('parse_yaml_line: Found single-line pattern')
         debug_log('  Indent: "' .. indent .. '"')
         debug_log('  Key: "' .. key .. '"')
         debug_log('  Value: "' .. value .. '"')
         debug_log('  Suffix: "' .. suffix .. '"')
       end
      return {
        indent = indent,
        key = key,
        value = value,
        suffix = suffix,
        original = content,
        is_vault_format = false
      }
    end
  end

        if M.debug_mode then
     debug_log('parse_yaml_line: No pattern matched')
     debug_log('  First line: "' .. first_line .. '"')
   end

  return nil
end

-- Reconstruct YAML line with new value
local function reconstruct_yaml_line(parsed, new_value, original_was_quoted)
  if not parsed then return nil end

  -- Check if this is an encrypted value (starts with !vault)
  local is_vault_value = new_value:match('^!vault%s*|')

  local quote_char = ''
  if not is_vault_value and (original_was_quoted or new_value:match('[%s#:]') or new_value:match('^%$ANSIBLE_VAULT')) then
    quote_char = '"'
    -- Escape quotes in the value
    new_value = new_value:gsub('"', '\\"')
  end

  return string.format('%s%s: %s%s%s%s',
    parsed.indent,
    parsed.key,
    quote_char,
    new_value,
    quote_char,
    parsed.suffix
  )
end

-- Check if content appears to be a YAML key-value line
local function is_yaml_key_value(content)
  -- Remove leading/trailing whitespace
  local trimmed = content:match('^%s*(.-)%s*$')

  -- Allow multi-line content for !vault format
  return parse_yaml_line(trimmed) ~= nil
end

-- Encrypt selection or range
function M.encrypt(line1, line2)
  local content
  if line1 and line2 then
    content = get_range_content(line1, line2)
  else
    content = get_visual_selection()
    line1 = vim.fn.getpos("'<")[2]
    line2 = vim.fn.getpos("'>")[2]
  end

  if content == '' then
    vim.api.nvim_echo({{'Error: No text selected', 'ErrorMsg'}}, true, {})
    return
  end

  -- Check if content is already encrypted
  if is_vault_encrypted(content) then
    vim.api.nvim_echo({{'Error: Content is already encrypted', 'ErrorMsg'}}, true, {})
    return
  end

  -- Debug: show content length and type
  if M.debug_mode then
    vim.api.nvim_echo({
      {'Debug: Encrypting ' .. string.len(content) .. ' characters', 'Comment'}
    }, false, {})
  end

  local output = execute_vault_command('encrypt', content)

  if output then
    replace_range(line1, line2, output)
    vim.api.nvim_echo({{'Text encrypted successfully!', 'Normal'}}, true, {})
  else
    vim.api.nvim_echo({{'Encryption failed! Check error messages above.', 'ErrorMsg'}}, true, {})
  end
end

-- Decrypt selection or range
function M.decrypt(line1, line2)
  local content
  if line1 and line2 then
    content = get_range_content(line1, line2)
  else
    content = get_visual_selection()
    line1 = vim.fn.getpos("'<")[2]
    line2 = vim.fn.getpos("'>")[2]
  end

  if content == '' then
    vim.api.nvim_err_writeln('Error: No text selected')
    return
  end

  -- Check if content is actually encrypted
  if is_plain_text(content) then
    vim.api.nvim_err_writeln('Error: Content is not vault encrypted')
    return
  end

  local output = execute_vault_command('decrypt', content)

  if output then
    replace_range(line1, line2, output)
    vim.api.nvim_echo({{'Text decrypted successfully!', 'Normal'}}, true, {})
  else
    vim.api.nvim_echo({{'Decryption failed! Check error messages above.', 'ErrorMsg'}}, true, {})
  end
end

-- View (decrypt without replacing) selection or range
function M.view(line1, line2)
  local content
  if line1 and line2 then
    content = get_range_content(line1, line2)
  else
    content = get_visual_selection()
  end

  if content == '' then
    vim.api.nvim_err_writeln('Error: No text selected')
    return
  end

  -- Check if content is actually encrypted
  if is_plain_text(content) then
    vim.api.nvim_err_writeln('Error: Content is not vault encrypted')
    return
  end

  local output = execute_vault_command('view', content)

  if output then
    -- Display in a new scratch buffer
    vim.cmd('new')
    vim.cmd('setlocal buftype=nofile bufhidden=wipe noswapfile')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, '\n'))
    vim.api.nvim_echo({{'Vault content displayed in new buffer', 'Normal'}}, false, {})
  end
end

-- Encrypt entire file
function M.encrypt_file()
  local filepath = vim.fn.expand('%:p')
  if filepath == '' then
    vim.api.nvim_err_writeln('Error: No file loaded')
    return
  end

  -- Save file first
  vim.cmd('write')

  if execute_vault_file_command('encrypt', filepath) then
    vim.cmd('edit!') -- Reload the file
    vim.api.nvim_echo({{'File encrypted successfully!', 'Normal'}}, false, {})
  end
end

-- Decrypt entire file
function M.decrypt_file()
  local filepath = vim.fn.expand('%:p')
  if filepath == '' then
    vim.api.nvim_err_writeln('Error: No file loaded')
    return
  end

  if execute_vault_file_command('decrypt', filepath) then
    vim.cmd('edit!') -- Reload the file
    vim.api.nvim_echo({{'File decrypted successfully!', 'Normal'}}, false, {})
  end
end

-- Edit vault file (decrypt, edit, then encrypt on save)
function M.edit_file()
  local filepath = vim.fn.expand('%:p')
  if filepath == '' then
    vim.api.nvim_err_writeln('Error: No file loaded')
    return
  end

  -- Create a temporary decrypted version
  local vault_cmd = build_vault_command('view', filepath)
  local handle = io.popen(vault_cmd)
  local content = handle:read('*all')
  local success, _, exit_code = handle:close()

  if not success or exit_code ~= 0 then
    vim.api.nvim_err_writeln('Failed to decrypt file for editing')
    return
  end

  -- Replace buffer content with decrypted version
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, '\n'))

  -- Set up auto-command to encrypt on save
  vim.cmd([[
    augroup AnsibleVaultEdit
      autocmd! * <buffer>
      autocmd BufWritePre <buffer> lua require('ansible-vault').encrypt_on_save()
    augroup END
  ]])

  vim.api.nvim_echo({{'File decrypted for editing. Will auto-encrypt on save.', 'Normal'}}, false, {})
end

-- Auto-encrypt on save (used by edit_file)
function M.encrypt_on_save()
  local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
  local output = execute_vault_command('encrypt', content)

  if output then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, '\n'))
  end
end

-- Rekey vault file
function M.rekey_file()
  local filepath = vim.fn.expand('%:p')
  if filepath == '' then
    vim.api.nvim_err_writeln('Error: No file loaded')
    return
  end

  if execute_vault_file_command('rekey', filepath) then
    vim.cmd('edit!') -- Reload the file
    vim.api.nvim_echo({{'File rekeyed successfully!', 'Normal'}}, false, {})
  end
end

-- Interactive encrypt with options
function M.encrypt_prompt(line1, line2)
  local vault_id = vim.fn.input('Vault ID (optional): ')
  local extra_args = ''
  if vault_id ~= '' then
    extra_args = '--vault-id=' .. vault_id .. ' --encrypt-vault-id=' .. vault_id
  end

  local content
  if line1 and line2 then
    content = get_range_content(line1, line2)
  else
    content = get_visual_selection()
    line1 = vim.fn.getpos("'<")[2]
    line2 = vim.fn.getpos("'>")[2]
  end

  if content == '' then
    vim.api.nvim_err_writeln('Error: No text selected')
    return
  end

  -- Check if content is already encrypted
  if is_vault_encrypted(content) then
    vim.api.nvim_err_writeln('Error: Content is already encrypted')
    return
  end

  local output = execute_vault_encrypt_string(content, extra_args)

  if output then
    replace_range(line1, line2, output)
    vim.api.nvim_echo({{'Text encrypted successfully!', 'Normal'}}, false, {})
  end
end

-- Interactive decrypt with options
function M.decrypt_prompt(line1, line2)
  local vault_id = vim.fn.input('Vault ID (optional): ')
  local extra_args = vault_id ~= '' and ('--vault-id=' .. vault_id) or ''

  local content
  if line1 and line2 then
    content = get_range_content(line1, line2)
  else
    content = get_visual_selection()
    line1 = vim.fn.getpos("'<")[2]
    line2 = vim.fn.getpos("'>")[2]
  end

  if content == '' then
    vim.api.nvim_err_writeln('Error: No text selected')
    return
  end

  -- Check if content is actually encrypted
  if is_plain_text(content) then
    vim.api.nvim_err_writeln('Error: Content is not vault encrypted')
    return
  end

  local output = execute_vault_command('decrypt', content, extra_args)

  if output then
    replace_range(line1, line2, output)
    vim.api.nvim_echo({{'Text decrypted successfully!', 'Normal'}}, false, {})
  end
end

-- Operator functions
function M.encrypt_operator(start_line, end_line, content)
  -- Check if content is already encrypted
  if is_vault_encrypted(content) then
    vim.api.nvim_err_writeln('Error: Content is already encrypted')
    return
  end

  local output = execute_vault_command('encrypt', content)

  if output then
    replace_range(start_line, end_line, output)
    vim.api.nvim_echo({{'Text encrypted successfully!', 'Normal'}}, false, {})
  end
end

function M.decrypt_operator(start_line, end_line, content)
  -- Check if content is actually encrypted
  if is_plain_text(content) then
    vim.api.nvim_err_writeln('Error: Content is not vault encrypted')
    return
  end

  local output = execute_vault_command('decrypt', content)

  if output then
    replace_range(start_line, end_line, output)
    vim.api.nvim_echo({{'Text decrypted successfully!', 'Normal'}}, false, {})
  end
end

-- Encrypt YAML value only (smart YAML handling)
function M.encrypt_yaml_value(line1, line2)
  local content
  if line1 and line2 then
    content = get_range_content(line1, line2)
  else
    content = get_visual_selection()
    line1 = vim.fn.getpos("'<")[2]
    line2 = vim.fn.getpos("'>")[2]
  end

  if content == '' then
    vim.api.nvim_echo({{'Error: No text selected', 'ErrorMsg'}}, true, {})
    return
  end

  -- Check if this is a YAML key-value line
  if not is_yaml_key_value(content) then
    vim.api.nvim_echo({{'Error: Selected content is not a YAML key-value pair', 'ErrorMsg'}}, true, {})
    return
  end

  local parsed = parse_yaml_line(content:match('^%s*(.-)%s*$'))
  if not parsed then
    vim.api.nvim_echo({{'Error: Could not parse YAML line', 'ErrorMsg'}}, true, {})
    return
  end

  -- Check if value is already encrypted
  if is_vault_encrypted(parsed.value) then
    vim.api.nvim_echo({{'Error: Value is already encrypted', 'ErrorMsg'}}, true, {})
    return
  end

  if M.debug_mode then
    local value_preview = parsed.value:sub(1, 50):gsub('\n', '\\n')
    vim.api.nvim_echo({
      {'Debug: Encrypting YAML value "' .. value_preview .. '..." for key "' .. parsed.key .. '"', 'Comment'},
      {'\nValue length: ' .. string.len(parsed.value) .. ' chars', 'Comment'},
      {'\nMultiline indicator: ' .. tostring(parsed.multiline_indicator or 'none'), 'Comment'}
    }, false, {})
  end

  -- Encrypt only the value using encrypt_string
  local encrypted_value = execute_vault_encrypt_string(parsed.value)

    if encrypted_value then
    -- Check if the encrypted value is multi-line (!vault format)
    if encrypted_value:match('!vault%s*|') then
      -- For !vault format, create proper YAML structure
      local vault_lines = vim.split(encrypted_value, '\n')
      local new_lines = {}

      -- First line: key: !vault |
      table.insert(new_lines, parsed.indent .. parsed.key .. ': ' .. vault_lines[1] .. parsed.suffix)

      -- Subsequent lines: indented vault content
      for i = 2, #vault_lines do
        if vault_lines[i] ~= '' then
          table.insert(new_lines, parsed.indent .. '  ' .. vault_lines[i])
        end
      end

      local new_content = table.concat(new_lines, '\n')
      replace_range(line1, line2, new_content)
      vim.api.nvim_echo({{'YAML value encrypted successfully!', 'Normal'}}, true, {})
    else
      -- Fallback to regular reconstruction for non-vault formats
      local original_was_quoted = content:match('"') ~= nil or content:match("'") ~= nil
      local new_line = reconstruct_yaml_line(parsed, encrypted_value, original_was_quoted)

      if new_line then
        replace_range(line1, line2, new_line)
        vim.api.nvim_echo({{'YAML value encrypted successfully!', 'Normal'}}, true, {})
      else
        vim.api.nvim_echo({{'Error: Failed to reconstruct YAML line', 'ErrorMsg'}}, true, {})
      end
    end
  else
    vim.api.nvim_echo({{'Encryption failed! Check error messages above.', 'ErrorMsg'}}, true, {})
  end
end

-- Decrypt YAML value only (smart YAML handling)
function M.decrypt_yaml_value(line1, line2)
  local content
  if line1 and line2 then
    content = get_range_content(line1, line2)
  else
    content = get_visual_selection()
    line1 = vim.fn.getpos("'<")[2]
    line2 = vim.fn.getpos("'>")[2]
  end

  if M.debug_mode then
    local content_preview = content:sub(1, 100):gsub('\n', '\\n')
    debug_log('decrypt_yaml_value: Processing content')
    debug_log('  Lines: ' .. line1 .. '-' .. line2)
    debug_log('  Content preview: "' .. content_preview .. '..."')
    debug_log('  Content length: ' .. string.len(content))
  end

  if content == '' then
    vim.api.nvim_echo({{'Error: No text selected', 'ErrorMsg'}}, true, {})
    return
  end

  -- Check if this is a YAML key-value line
  if not is_yaml_key_value(content) then
    vim.api.nvim_echo({{'Error: Selected content is not a YAML key-value pair', 'ErrorMsg'}}, true, {})
    return
  end

  local parsed = parse_yaml_line(content:match('^%s*(.-)%s*$'))
  if not parsed then
    vim.api.nvim_echo({{'Error: Could not parse YAML line', 'ErrorMsg'}}, true, {})
    return
  end

  -- Check if value is actually encrypted
  if is_plain_text(parsed.value) then
    vim.api.nvim_echo({{'Error: Value is not vault encrypted', 'ErrorMsg'}}, true, {})
    return
  end

  if M.debug_mode then
    local value_preview = parsed.value:sub(1, 50):gsub('\n', '\\n')
    vim.api.nvim_echo({
      {'Debug: Decrypting YAML value for key "' .. parsed.key .. '"', 'Comment'},
      {'\nParsed value preview: "' .. value_preview .. '..."', 'Comment'},
      {'\nValue length: ' .. string.len(parsed.value) .. ' chars', 'Comment'},
      {'\nIs vault format: ' .. tostring(parsed.is_vault_format or false), 'Comment'},
      {'\nMultiline indicator: ' .. tostring(parsed.multiline_indicator or 'none'), 'Comment'}
    }, false, {})
  end

  -- Decrypt only the value
  local decrypted_value = execute_vault_command('decrypt', parsed.value)

      if decrypted_value then
    -- Reconstruct the line with decrypted value
    if parsed.is_vault_format then
      -- For !vault format, create a simple key: value line (could be single or multi-line)
      if decrypted_value:match('\n') then
        -- Multi-line decrypted content, recreate as YAML multi-line
        local lines = vim.split(decrypted_value, '\n')
        local new_lines = {}
        table.insert(new_lines, parsed.indent .. parsed.key .. ': |' .. parsed.suffix)
        for _, line in ipairs(lines) do
          table.insert(new_lines, parsed.indent .. '  ' .. line)
        end
        local new_content = table.concat(new_lines, '\n')
        replace_range(line1, line2, new_content)
      else
        -- Single-line decrypted content
        local new_line = parsed.indent .. parsed.key .. ': "' .. decrypted_value .. '"' .. parsed.suffix
        replace_range(line1, line2, new_line)
      end
      vim.api.nvim_echo({{'YAML value decrypted successfully!', 'Normal'}}, true, {})
    else
      -- For regular multi-line format, preserve original structure if it was multi-line
      if parsed.multiline_indicator then
        -- Reconstruct multi-line format
        local lines = vim.split(decrypted_value, '\n')
        local new_lines = {}
        table.insert(new_lines, parsed.indent .. parsed.key .. ': |' .. parsed.suffix)
        for _, line in ipairs(lines) do
          table.insert(new_lines, parsed.indent .. '  ' .. line)
        end
        local new_content = table.concat(new_lines, '\n')
        replace_range(line1, line2, new_content)
      else
        -- Single-line format
        local original_was_quoted = content:match('"') ~= nil or content:match("'") ~= nil
        local new_line = reconstruct_yaml_line(parsed, decrypted_value, false)

        if new_line then
          replace_range(line1, line2, new_line)
        else
          vim.api.nvim_echo({{'Error: Failed to reconstruct YAML line', 'ErrorMsg'}}, true, {})
          return
        end
      end
      vim.api.nvim_echo({{'YAML value decrypted successfully!', 'Normal'}}, true, {})
    end
  else
    vim.api.nvim_echo({{'Decryption failed! Check error messages above.', 'ErrorMsg'}}, true, {})
  end
end

-- Enhanced encrypt that auto-detects YAML and automatically encrypts value only
function M.encrypt_smart(line1, line2)
  local content
  if line1 and line2 then
    content = get_range_content(line1, line2)
  else
    content = get_visual_selection()
    line1 = vim.fn.getpos("'<")[2]
    line2 = vim.fn.getpos("'>")[2]
  end

  if content == '' then
    vim.api.nvim_echo({{'Error: No text selected', 'ErrorMsg'}}, true, {})
    return
  end

  -- Check if this looks like a YAML key-value pair
  if is_yaml_key_value(content) then
    if M.debug_mode then
      vim.api.nvim_echo({{'Debug: Auto-detected YAML, encrypting value only', 'Comment'}}, false, {})
    end
    -- Automatically encrypt value only for YAML
    M.encrypt_yaml_value(line1, line2)
    return
  end

  -- Normal encryption for non-YAML content
  M.encrypt(line1, line2)
end

-- Enhanced decrypt that auto-detects YAML and automatically decrypts value only
function M.decrypt_smart(line1, line2)
  local content
  if line1 and line2 then
    content = get_range_content(line1, line2)
  else
    content = get_visual_selection()
    line1 = vim.fn.getpos("'<")[2]
    line2 = vim.fn.getpos("'>")[2]
  end

  if content == '' then
    vim.api.nvim_echo({{'Error: No text selected', 'ErrorMsg'}}, true, {})
    return
  end

  -- Check if this looks like a YAML key-value pair
  if is_yaml_key_value(content) then
    if M.debug_mode then
      vim.api.nvim_echo({{'Debug: Auto-detected YAML, decrypting value only', 'Comment'}}, false, {})
    end
    -- Automatically decrypt value only for YAML
    M.decrypt_yaml_value(line1, line2)
    return
  end

  -- Normal decryption for non-YAML content
  M.decrypt(line1, line2)
end

-- Enhanced encrypt with user prompt (for when you want to override smart behavior)
function M.encrypt_with_prompt(line1, line2)
  local content
  if line1 and line2 then
    content = get_range_content(line1, line2)
  else
    content = get_visual_selection()
    line1 = vim.fn.getpos("'<")[2]
    line2 = vim.fn.getpos("'>")[2]
  end

  if content == '' then
    vim.api.nvim_echo({{'Error: No text selected', 'ErrorMsg'}}, true, {})
    return
  end

  -- Check if this looks like a YAML key-value pair
  if is_yaml_key_value(content) then
    local choice = vim.fn.confirm(
      'Detected YAML key-value pair. How do you want to encrypt?',
      '&Value only\n&Entire selection\n&Cancel',
      1
    )

    if choice == 1 then
      -- Encrypt value only
      M.encrypt_yaml_value(line1, line2)
      return
    elseif choice == 2 then
      -- Fall through to normal encryption
    else
      -- Cancel
      return
    end
  end

  -- Normal encryption for non-YAML or user choice
  M.encrypt(line1, line2)
end

-- Enhanced decrypt with user prompt (for when you want to override smart behavior)
function M.decrypt_with_prompt(line1, line2)
  local content
  if line1 and line2 then
    content = get_range_content(line1, line2)
  else
    content = get_visual_selection()
    line1 = vim.fn.getpos("'<")[2]
    line2 = vim.fn.getpos("'>")[2]
  end

  if content == '' then
    vim.api.nvim_echo({{'Error: No text selected', 'ErrorMsg'}}, true, {})
    return
  end

  -- Check if this looks like a YAML key-value pair
  if is_yaml_key_value(content) then
    local choice = vim.fn.confirm(
      'Detected YAML key-value pair. How do you want to decrypt?',
      '&Value only\n&Entire selection\n&Cancel',
      1
    )

    if choice == 1 then
      -- Decrypt value only
      M.decrypt_yaml_value(line1, line2)
      return
    elseif choice == 2 then
      -- Fall through to normal decryption
    else
      -- Cancel
      return
    end
  end

  -- Normal decryption for non-YAML or user choice
  M.decrypt(line1, line2)
end

-- Find complete YAML key-value structure around cursor
local function find_yaml_structure_at_cursor()
  local cursor_line = vim.fn.line('.')
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Check if current line starts a YAML key-value pair
  local current_line = lines[cursor_line]
  if not current_line then
    return nil
  end

  -- Check if this line has a key: pattern
  local indent, key = current_line:match('^(%s*)([%w_%-]+):%s*')
  if not indent or not key then
    return nil
  end

  local start_line = cursor_line
  local end_line = cursor_line
  local base_indent_len = #indent

  -- Check if this is a multi-line structure (either !vault format or regular YAML multi-line)
  local is_multiline = current_line:match('!vault%s*|') or
                       current_line:match('|%s*$') or
                       current_line:match('>%s*$') or
                       current_line:match('|%s*#') or
                       current_line:match('>%s*#')

  if is_multiline then
    -- Find the end of the multi-line block by looking for lines with proper indentation
    for i = cursor_line + 1, #lines do
      local line = lines[i]
      if line:match('^%s*$') then
        -- Skip empty lines within the block
        end_line = i
      elseif line:match('^%s') then
        local line_indent = line:match('^(%s*)')
        if #line_indent > base_indent_len then
          -- This line is more indented, part of the multi-line content
          end_line = i
        else
          -- This line is at same or less indentation, end of multi-line block
          break
        end
      else
        -- Non-indented line, end of block
        break
      end
    end
  end

  return {
    start_line = start_line,
    end_line = end_line,
    content = table.concat(vim.list_slice(lines, start_line, end_line), '\n')
  }
end

-- Decrypt YAML structure at cursor position
function M.decrypt_at_cursor()
  local structure = find_yaml_structure_at_cursor()
  if not structure then
    vim.api.nvim_echo({{'Error: No YAML key-value structure found at cursor', 'ErrorMsg'}}, true, {})
    return
  end

         if M.debug_mode then
     local content_preview = structure.content:sub(1, 100):gsub('\n', '\\n')
     debug_log('decrypt_at_cursor: Found YAML structure at lines ' .. structure.start_line .. '-' .. structure.end_line)
     debug_log('  Content preview: "' .. content_preview .. '..."')
   end

  -- Use the existing decrypt_yaml_value function
  M.decrypt_yaml_value(structure.start_line, structure.end_line)
end

-- Encrypt YAML structure at cursor position
function M.encrypt_at_cursor()
  local structure = find_yaml_structure_at_cursor()
  if not structure then
    vim.api.nvim_echo({{'Error: No YAML key-value structure found at cursor', 'ErrorMsg'}}, true, {})
    return
  end

            if M.debug_mode then
     local content_preview = structure.content:sub(1, 100):gsub('\n', '\\n')
     debug_log('encrypt_at_cursor: Found YAML structure at lines ' .. structure.start_line .. '-' .. structure.end_line)
     debug_log('  Content preview: "' .. content_preview .. '..."')
   end

  -- Use the existing encrypt_yaml_value function
  M.encrypt_yaml_value(structure.start_line, structure.end_line)
end

-- Smart encrypt/decrypt at cursor (detects YAML automatically)
function M.smart_at_cursor()
  local structure = find_yaml_structure_at_cursor()
  if not structure then
    vim.api.nvim_echo({{'Error: No YAML key-value structure found at cursor', 'ErrorMsg'}}, true, {})
    return
  end

  -- Check if it's encrypted and choose appropriate action
  if is_vault_encrypted(structure.content) then
    M.decrypt_at_cursor()
  else
    M.encrypt_at_cursor()
  end
end

-- Toggle debug mode
function M.toggle_debug()
  M.debug_mode = not M.debug_mode
  local status = M.debug_mode and 'enabled' or 'disabled'
  local log_file = vim.fn.expand('~/.config/nvim/ansible-vault-debug.log')
  vim.api.nvim_echo({
    {'Ansible Vault debug mode ' .. status, 'Normal'},
    {'\nLog file: ' .. log_file, 'Comment'}
  }, true, {})
end

-- View debug log
function M.view_debug_log()
  local log_file = vim.fn.expand('~/.config/nvim/ansible-vault-debug.log')
  if vim.fn.filereadable(log_file) == 1 then
    vim.cmd('edit ' .. log_file)
  else
    vim.api.nvim_echo({{'No debug log found at: ' .. log_file, 'WarningMsg'}}, true, {})
  end
end

-- Clear debug log
function M.clear_debug_log()
  local log_file = vim.fn.expand('~/.config/nvim/ansible-vault-debug.log')
  local file = io.open(log_file, 'w')
  if file then
    file:close()
    vim.api.nvim_echo({{'Debug log cleared', 'Normal'}}, true, {})
  else
    vim.api.nvim_echo({{'Failed to clear debug log', 'ErrorMsg'}}, true, {})
  end
end

return M