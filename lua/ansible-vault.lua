-- ansible-vault.lua - Neovim ansible-vault plugin core functionality

local M = {}

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
    vim.api.nvim_err_writeln('ansible-vault ' .. operation .. ' failed')
    vim.api.nvim_err_writeln('Output: ' .. output)
    return nil
  end

  -- Remove trailing newline if present
  output = output:gsub('\n$', '')

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

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  if #lines == 0 then
    return ''
  end

  -- Handle single line selection
  if #lines == 1 then
    return lines[1]:sub(start_col, end_col)
  end

  -- Handle multi-line selection
  lines[1] = lines[1]:sub(start_col)
  lines[#lines] = lines[#lines]:sub(1, end_col)

  return table.concat(lines, '\n')
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
    vim.api.nvim_err_writeln('Error: No text selected')
    return
  end

  local output = execute_vault_command('encrypt', content)

  if output then
    replace_range(line1, line2, output)
    vim.api.nvim_echo({{'Text encrypted successfully!', 'Normal'}}, false, {})
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

  local output = execute_vault_command('decrypt', content)

  if output then
    replace_range(line1, line2, output)
    vim.api.nvim_echo({{'Text decrypted successfully!', 'Normal'}}, false, {})
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

  local output = execute_vault_command('encrypt', content, extra_args)

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

  local output = execute_vault_command('decrypt', content, extra_args)

  if output then
    replace_range(line1, line2, output)
    vim.api.nvim_echo({{'Text decrypted successfully!', 'Normal'}}, false, {})
  end
end

-- Operator functions
function M.encrypt_operator(start_line, end_line, content)
  local output = execute_vault_command('encrypt', content)

  if output then
    replace_range(start_line, end_line, output)
    vim.api.nvim_echo({{'Text encrypted successfully!', 'Normal'}}, false, {})
  end
end

function M.decrypt_operator(start_line, end_line, content)
  local output = execute_vault_command('decrypt', content)

  if output then
    replace_range(start_line, end_line, output)
    vim.api.nvim_echo({{'Text decrypted successfully!', 'Normal'}}, false, {})
  end
end

return M