# Neovim Ansible Vault Plugin

A specialized Neovim plugin for working with Ansible Vault encrypted content. Encrypt, decrypt, and manage vault content directly within Neovim with seamless integration.

## Features

- **Encrypt/Decrypt selections** - Work with specific parts of files
- **Full file operations** - Encrypt, decrypt, and rekey entire files
- **Vault viewing** - Preview encrypted content without modifying
- **Interactive editing** - Edit vault files with auto-encrypt on save
- **Configurable authentication** - Support for password files and vault IDs
- **Auto-detection** - Automatically detect Ansible vault files
- **Operator mode support** - Works with Vim text objects

## Installation

### Using vim-plug
```vim
Plug 'your-username/neovim-ansible-vault'
```

### Using packer.nvim
```lua
use 'your-username/neovim-ansible-vault'
```

### Using lazy.nvim

#### From GitHub
```lua
{
  'your-username/neovim-ansible-vault',
  ft = { 'yaml', 'yaml.ansible', 'ansible-vault' }, -- Load for YAML, Ansible YAML and vault files
  config = function()
    -- Optional configuration
    vim.g.ansible_vault_password_file = '~/.ansible/vault_pass'
    vim.g.ansible_vault_identity = 'default@~/.ansible/vault_pass'
  end,
}
```

#### From Local Directory
```lua
{
  dir = '~/path/to/neovim-ansible-vault', -- Local filesystem path
  name = 'neovim-ansible-vault',
  ft = { 'yaml', 'yaml.ansible', 'ansible-vault' },
  config = function()
    -- Optional configuration
    vim.g.ansible_vault_password_file = '~/.ansible/vault_pass'
    vim.g.ansible_vault_identity = 'default@~/.ansible/vault_pass'
  end,
}
```

### Manual Installation
Clone this repository into your Neovim configuration directory:
```bash
git clone https://github.com/your-username/neovim-ansible-vault.git ~/.config/nvim/pack/plugins/start/neovim-ansible-vault
```

## Configuration

### Basic Configuration
```vim
" Optional: Set password file path
let g:ansible_vault_password_file = '~/.ansible/vault_pass'

" Optional: Set vault identity
let g:ansible_vault_identity = 'default@~/.ansible/vault_pass'

" Optional: Disable default key mappings
let g:ansible_vault_no_mappings = 1
```

### Lua Configuration (init.lua)
```lua
vim.g.ansible_vault_password_file = '~/.ansible/vault_pass'
vim.g.ansible_vault_identity = 'default@~/.ansible/vault_pass'
```

## Usage

### Commands

#### Selection/Range Commands
- `:VaultEncrypt` - Encrypt selected text or range
- `:VaultDecrypt` - Decrypt selected text or range
- `:VaultView` - View decrypted content in new buffer (read-only)

#### File Commands
- `:VaultEncryptFile` - Encrypt entire current file
- `:VaultDecryptFile` - Decrypt entire current file
- `:VaultEditFile` - Edit vault file (decrypt for editing, auto-encrypt on save)
- `:VaultRekey` - Change vault password/key for current file

#### Interactive Commands
- `:VaultEncryptPrompt` - Encrypt with vault ID prompt
- `:VaultDecryptPrompt` - Decrypt with vault ID prompt

### Default Key Mappings

#### Visual Mode (selection-based)
- `<leader>ve` - Encrypt selection
- `<leader>vd` - Decrypt selection
- `<leader>vv` - View decrypted selection

#### Normal Mode (file-based)
- `<leader>vE` - Encrypt entire file
- `<leader>vD` - Decrypt entire file
- `<leader>vF` - Edit vault file (decrypt → edit → auto-encrypt)
- `<leader>vR` - Rekey file

#### Operator Mode (works with text objects)
- `<leader>ve{motion}` - Encrypt text object (e.g., `<leader>veiw` for inner word)
- `<leader>vd{motion}` - Decrypt text object

### Examples

#### 1. Working with Selections
```vim
" Select some text in visual mode, then:
:'<,'>VaultEncrypt

" Or use the mapping:
" 1. Select text in visual mode
" 2. Press <leader>ve
```

#### 2. File Operations
```vim
" Encrypt the entire current file
:VaultEncryptFile

" Edit a vault file safely
:VaultEditFile
" Make your changes, then save - it will auto-encrypt
```

#### 3. Working with Text Objects
```vim
" Encrypt the current paragraph
<leader>veip

" Decrypt the current word
<leader>vdiw

" Encrypt everything inside quotes
<leader>vei"
```

#### 4. Viewing Vault Content
```vim
" Select encrypted content and view it decrypted
:'<,'>VaultView
" Opens in a new buffer showing decrypted content
```

#### 5. Using Vault IDs
```vim
" Encrypt with specific vault ID
:'<,'>VaultEncryptPrompt
" Will prompt: "Vault ID (optional): staging"
```

## Workflow Examples

### Editing Encrypted Variables
```vim
" Open your vars file
:e group_vars/production/vault.yml

" If it's encrypted, edit it safely
:VaultEditFile
" The file is now decrypted for editing

" Make your changes...
:w
" File is automatically re-encrypted on save
```

### Managing Mixed Content Files
```vim
" For files with both encrypted and plain text:

" 1. Select only the encrypted portion
" 2. Press <leader>vd to decrypt just that section
" 3. Edit the decrypted content
" 4. Select the modified section
" 5. Press <leader>ve to re-encrypt
```

### Quick Content Inspection
```vim
" To quickly peek at encrypted content:
" 1. Select the encrypted text
" 2. Press <leader>vv
" 3. Content opens in new buffer for viewing
" 4. Close when done - original remains encrypted
```

## File Auto-Detection

The plugin automatically detects Ansible vault files based on:
- Files starting with `$ANSIBLE_VAULT`
- Files in common Ansible directories: `*/vars/*`, `*/group_vars/*`, `*/host_vars/*`, `*/inventory/*`
- Files with `yaml.ansible` filetype that contain vault content

## Error Handling

The plugin provides clear error messages for common issues:
- Missing ansible-vault command
- Authentication failures
- Invalid vault format
- File permission issues

## Requirements

- Neovim 0.5+ (for Lua support)
- `ansible-vault` command available in PATH
- Proper Ansible vault authentication configured

## Troubleshooting

### Authentication Issues
```bash
# Set up password file
echo "your_vault_password" > ~/.ansible/vault_pass
chmod 600 ~/.ansible/vault_pass

# Configure in Neovim
let g:ansible_vault_password_file = '~/.ansible/vault_pass'
```

### Multiple Vault IDs
```vim
" For projects with multiple vault identities
let g:ansible_vault_identity = 'prod@~/.ansible/prod_pass'

" Or use the prompt commands for per-operation vault ID selection
:VaultEncryptPrompt
```

## License

MIT License