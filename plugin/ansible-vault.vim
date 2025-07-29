" ansible-vault.vim - Neovim plugin for ansible-vault operations
" Author: Assistant
" Version: 1.0

if exists('g:loaded_ansible_vault')
  finish
endif
let g:loaded_ansible_vault = 1

" Save cpo setting and set it to Vim default
let s:save_cpo = &cpo
set cpo&vim

" Configuration variables
if !exists('g:ansible_vault_password_file')
  let g:ansible_vault_password_file = ''
endif

if !exists('g:ansible_vault_identity')
  let g:ansible_vault_identity = ''
endif

" Main ansible-vault commands
command! -range VaultEncrypt call luaeval('require("ansible-vault").encrypt(_A)', [<line1>, <line2>])
command! -range VaultDecrypt call luaeval('require("ansible-vault").decrypt(_A)', [<line1>, <line2>])

command! VaultEncryptFile call luaeval('require("ansible-vault").encrypt_file()')
command! VaultDecryptFile call luaeval('require("ansible-vault").decrypt_file()')
command! VaultEditFile call luaeval('require("ansible-vault").edit_file()')
command! VaultStopAutoEncrypt call luaeval('require("ansible-vault").stop_auto_encrypt()')
command! VaultRekey call luaeval('require("ansible-vault").rekey_file()')

" Interactive commands that prompt for options
command! -range VaultEncryptPrompt call luaeval('require("ansible-vault").encrypt_prompt(_A)', [<line1>, <line2>])
command! -range VaultDecryptPrompt call luaeval('require("ansible-vault").decrypt_prompt(_A)', [<line1>, <line2>])

" Debug commands
command! VaultToggleDebug call luaeval('require("ansible-vault").toggle_debug()')
command! VaultViewLog call luaeval('require("ansible-vault").view_debug_log()')
command! VaultClearLog call luaeval('require("ansible-vault").clear_debug_log()')

" YAML-aware commands
command! -range VaultEncryptValue call luaeval('require("ansible-vault").encrypt_yaml_value(_A)', [<line1>, <line2>])
command! -range VaultDecryptValue call luaeval('require("ansible-vault").decrypt_yaml_value(_A)', [<line1>, <line2>])
command! -range VaultEncryptSmart call luaeval('require("ansible-vault").encrypt_smart(_A)', [<line1>, <line2>])
command! -range VaultDecryptSmart call luaeval('require("ansible-vault").decrypt_smart(_A)', [<line1>, <line2>])

" Commands with prompts (to override smart behavior)
command! -range VaultEncryptPromptChoice call luaeval('require("ansible-vault").encrypt_with_prompt(_A)', [<line1>, <line2>])
command! -range VaultDecryptPromptChoice call luaeval('require("ansible-vault").decrypt_with_prompt(_A)', [<line1>, <line2>])

" Cursor-based commands (auto-find YAML structure)
command! VaultEncryptAtCursor call luaeval('require("ansible-vault").encrypt_at_cursor()')
command! VaultDecryptAtCursor call luaeval('require("ansible-vault").decrypt_at_cursor()')
command! VaultSmartAtCursor call luaeval('require("ansible-vault").smart_at_cursor()')

" Auto-detect ansible vault files
augroup AnsibleVault
  autocmd!
  " Detect ansible vault files by content
  autocmd BufRead,BufNewFile *.yml,*.yaml
    \ if getline(1) =~# '^\$ANSIBLE_VAULT' |
    \   setlocal filetype=ansible-vault |
    \ endif
  " Detect by common ansible directories
  autocmd BufRead,BufNewFile */vars/*.yml,*/vars/*.yaml,*/group_vars/*,*/host_vars/*,*/inventory/*
    \ setlocal filetype=ansible-vault
  " Handle yaml.ansible filetype for vault operations
  autocmd FileType yaml.ansible
    \ if getline(1) =~# '^\$ANSIBLE_VAULT' |
    \   setlocal filetype=ansible-vault |
    \ endif
augroup END

" Default key mappings (can be overridden by user)
if !exists('g:ansible_vault_no_mappings') || !g:ansible_vault_no_mappings
  " Global mappings for ansible-vault operations
  vnoremap <leader>ve :VaultEncryptSmart<CR>
  vnoremap <leader>vd :VaultDecryptSmart<CR>

  nnoremap <leader>vE :VaultEncryptFile<CR>
  nnoremap <leader>vD :VaultDecryptFile<CR>
  nnoremap <leader>vF :VaultEditFile<CR>
  nnoremap <leader>vR :VaultRekey<CR>

    " YAML-specific mappings
  vnoremap <leader>vev :VaultEncryptValue<CR>
  vnoremap <leader>vdv :VaultDecryptValue<CR>

  " Original full-selection mappings
  vnoremap <leader>vef :VaultEncrypt<CR>
  vnoremap <leader>vdf :VaultDecrypt<CR>

    " Prompt-based mappings (override smart behavior)
  vnoremap <leader>vep :VaultEncryptPromptChoice<CR>
  vnoremap <leader>vdp :VaultDecryptPromptChoice<CR>

  " Cursor-based mappings (auto-find YAML structure)
  nnoremap <leader>vc :VaultSmartAtCursor<CR>
  nnoremap <leader>vec :VaultEncryptAtCursor<CR>
  nnoremap <leader>vdc :VaultDecryptAtCursor<CR>

  " Operator mode mappings (work with text objects)
  nnoremap <leader>ve :set operatorfunc=VaultEncryptOperator<CR>g@
  nnoremap <leader>vd :set operatorfunc=VaultDecryptOperator<CR>g@
endif

" Operator functions for normal mode usage
function! VaultEncryptOperator(type)
  let saved_reg = @"

  if a:type ==# 'v'
    normal! `<v`>y
  elseif a:type ==# 'char'
    normal! `[v`]y
  elseif a:type ==# 'line'
    normal! '[V']y
  else
    return
  endif

  let content = @"
  let @" = saved_reg

  " Get line numbers for the selection
  let start_line = line("'[")
  let end_line = line("']")

  call luaeval('require("ansible-vault").encrypt_operator(_A)', [start_line, end_line, content])
endfunction

function! VaultDecryptOperator(type)
  let saved_reg = @"

  if a:type ==# 'v'
    normal! `<v`>y
  elseif a:type ==# 'char'
    normal! `[v`]y
  elseif a:type ==# 'line'
    normal! '[V']y
  else
    return
  endif

  let content = @"
  let @" = saved_reg

  " Get line numbers for the selection
  let start_line = line("'[")
  let end_line = line("']")

  call luaeval('require("ansible-vault").decrypt_operator(_A)', [start_line, end_line, content])
endfunction

" Additional file type specific mappings
autocmd FileType ansible-vault nnoremap <buffer> <leader>vf :VaultEditFile<CR>
autocmd FileType ansible-vault nnoremap <buffer> <leader>vs :VaultEncryptFile<CR>

" Mappings for yaml.ansible filetype
autocmd FileType yaml.ansible nnoremap <buffer> <leader>vf :VaultEditFile<CR>
autocmd FileType yaml.ansible nnoremap <buffer> <leader>vs :VaultEncryptFile<CR>

" Restore cpo setting
let &cpo = s:save_cpo
unlet s:save_cpo