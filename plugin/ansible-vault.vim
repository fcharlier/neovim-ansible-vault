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
command! -range VaultView call luaeval('require("ansible-vault").view(_A)', [<line1>, <line2>])
command! VaultEncryptFile call luaeval('require("ansible-vault").encrypt_file()')
command! VaultDecryptFile call luaeval('require("ansible-vault").decrypt_file()')
command! VaultEditFile call luaeval('require("ansible-vault").edit_file()')
command! VaultRekey call luaeval('require("ansible-vault").rekey_file()')

" Interactive commands that prompt for options
command! -range VaultEncryptPrompt call luaeval('require("ansible-vault").encrypt_prompt(_A)', [<line1>, <line2>])
command! -range VaultDecryptPrompt call luaeval('require("ansible-vault").decrypt_prompt(_A)', [<line1>, <line2>])

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
  vnoremap <leader>ve :VaultEncrypt<CR>
  vnoremap <leader>vd :VaultDecrypt<CR>
  vnoremap <leader>vv :VaultView<CR>
  nnoremap <leader>vE :VaultEncryptFile<CR>
  nnoremap <leader>vD :VaultDecryptFile<CR>
  nnoremap <leader>vF :VaultEditFile<CR>
  nnoremap <leader>vR :VaultRekey<CR>

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