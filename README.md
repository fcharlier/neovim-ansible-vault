# Neovim Ansible Vault Plugin

A specialized Neovim plugin for working with Ansible Vault encrypted content. Encrypt, decrypt, and manage vault content directly within Neovim with seamless integration.

## ⚠️ Important Warning

**This plugin has not been thoroughly tested and may lead to data corruption or loss of encrypted content.**

Please:
- **Always backup your vault files** before using this plugin
- **Test thoroughly** in non-production environments first
- **Use with caution** on important data
- Report any issues on the GitHub repository

## Features

- **Encrypt/Decrypt selections** - Work with specific parts of files
- **Full file operations** - Encrypt, decrypt, and rekey entire files
- **Interactive editing** - Edit vault files with auto-encrypt on save
- **Configurable authentication** - Support for password files and vault IDs
- **Auto-detection** - Automatically detect Ansible vault files
- **Operator mode support** - Works with Vim text objects
- **Comprehensive testing** - Full test suite with 24+ functions covered

## Installation

### Using vim-plug
```vim
Plug 'fcharlier/neovim-ansible-vault'
```

### Using packer.nvim
```lua
use 'fcharlier/neovim-ansible-vault'
```

### Using lazy.nvim

#### From GitHub
```lua
{
  'fcharlier/neovim-ansible-vault',
  ft = { 'yaml', 'yaml.ansible', 'ansible-vault' }, -- Load for YAML, Ansible YAML and vault files
  config = function()
    -- Optional configuration
    vim.g.ansible_vault_password_file = '~/.ansible/vault_pass'
    -- or - vim.g.ansible_vault_identity = 'default@~/.ansible/vault_pass'
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
    -- or - vim.g.ansible_vault_identity = 'default@~/.ansible/vault_pass'
  end,
}
```

### Manual Installation
Clone this repository into your Neovim configuration directory:
```bash
git clone https://github.com/fcharlier/neovim-ansible-vault.git ~/.config/nvim/pack/plugins/start/neovim-ansible-vault
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
> **Highlight:**
> The key feature of this plugin is the `<leader>vc` mapping, which *toggles encryption or decryption* of the YAML value or structure under the cursor.
>
> - Place your cursor on a YAML value or block and press `<leader>vc` in normal mode to automatically encrypt or decrypt that value, depending on its current state.
> - This makes it effortless to work with Ansible Vault in YAML files—no need to select text or run manual commands!

### Commands

#### Selection/Range Commands
- `:VaultEncrypt` - Encrypt selected text or range (full selection)
- `:VaultDecrypt` - Decrypt selected text or range (full selection)


#### YAML-Aware Commands (NEW!)
- `:VaultEncryptValue` - Encrypt only the value in YAML key-value pairs (uses `encrypt_string`)
- `:VaultDecryptValue` - Decrypt only the value in YAML key-value pairs
- `:VaultEncryptSmart` - Auto-encrypt YAML values (uses `encrypt_string`), full selection for others
- `:VaultDecryptSmart` - Auto-decrypt YAML values, full selection for others
- `:VaultEncryptPromptChoice` - Prompt for encrypt preference (override smart behavior)
- `:VaultDecryptPromptChoice` - Prompt for decrypt preference (override smart behavior)

#### Cursor-Based Commands (NEW!)
- `:VaultSmartAtCursor` - Auto-encrypt/decrypt YAML structure at cursor
- `:VaultEncryptAtCursor` - Encrypt YAML structure at cursor
- `:VaultDecryptAtCursor` - Decrypt YAML structure at cursor

#### File Commands
- `:VaultEncryptFile` - Encrypt entire current file
- `:VaultDecryptFile` - Decrypt entire current file
- `:VaultEditFile` - Edit vault file (decrypts buffer, encrypts to disk only on :w)
- `:VaultStopAutoEncrypt` - Stop auto-encryption for current buffer
- `:VaultRekey` - Change vault password/key for current file

#### Interactive Commands
- `:VaultEncryptPrompt` - Encrypt with vault ID prompt:
- `:VaultDecryptPrompt` - Decrypt with vault ID prompt

### Default Key Mappings

#### Visual Mode (selection-based)
- `<leader>ve` - Smart encrypt (auto-encrypts YAML values, full selection for others)
- `<leader>vd` - Smart decrypt (auto-decrypts YAML values, full selection for others)


#### YAML-Specific Visual Mode
- `<leader>vev` - Encrypt YAML value only (uses `encrypt_string`, preserves key structure)
- `<leader>vdv` - Decrypt YAML value only (preserves key structure)
- `<leader>vef` - Encrypt full selection (uses `encrypt`, original behavior)
- `<leader>vdf` - Decrypt full selection (original behavior)
- `<leader>vep` - Encrypt with prompt (override smart behavior)
- `<leader>vdp` - Decrypt with prompt (override smart behavior)

#### Normal Mode (file-based)
- `<leader>vE` - Encrypt entire file
- `<leader>vD` - Decrypt entire file
- `<leader>vF` - Edit vault file (decrypt → edit → auto-encrypt)
- `<leader>vR` - Rekey file

#### Cursor-Based Mode (NEW!)
- `<leader>vc` - Smart encrypt/decrypt YAML structure at cursor
- `<leader>vec` - Encrypt YAML structure at cursor
- `<leader>vdc` - Decrypt YAML structure at cursor

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
" Buffer shows decrypted content, file on disk stays encrypted
" Edit normally, then save when ready to encrypt to disk:
:w
" Buffer stays decrypted, file gets encrypted on disk
" When done editing:
:VaultStopAutoEncrypt
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

#### 4. YAML-Aware Operations (NEW!)
```vim
" Smart mode (automatically encrypts values for YAML):
" Select: database_password: "secret123"
" Press <leader>ve (automatically encrypts just the value)
" Result: database_password: "$ANSIBLE_VAULT;1.1;AES256;..."

" Direct YAML value operations:
" Select: api_key: "abc123"
<leader>vev  " Encrypts only the value
<leader>vdv  " Decrypts only the value

" Override smart behavior with prompts:
<leader>vep  " Prompts: Value only / Entire selection / Cancel
<leader>vdp  " Prompts for decrypt preference

" Preserves structure:
" redis_host: localhost  # comment
" becomes:
" redis_host: "$ANSIBLE_VAULT;1.1;..." # comment
```

#### 5. Cursor-Based Operations (NEW!)
```vim
" Position cursor anywhere on a YAML key-value line:
" cursor here → key: "secret"
<leader>vc  " Auto-encrypts to: key: !vault | ...

" Works with multi-line vault structures:
" cursor here → key: !vault |
"                 $ANSIBLE_VAULT;1.1;...
<leader>vc  " Auto-decrypts back to: key: "secret"

" No manual selection needed - plugin finds the complete structure!
```



#### 6. Using Vault IDs
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
" YAML-aware approach (recommended):
" 1. Select a YAML line like: password: "secret123"
" 2. Press <leader>vev to encrypt only the value
" 3. Result: password: "$ANSIBLE_VAULT;1.1;..."
" 4. To decrypt: select the line, press <leader>vdv

" Traditional approach:
" 1. Select only the encrypted portion
" 2. Press <leader>vdf to decrypt just that section
" 3. Edit the decrypted content
" 4. Select the modified section
" 5. Press <leader>vef to re-encrypt
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

### Testing Requirements (Optional)

For running the test suite:
- All tests run with just Neovim (no additional dependencies required)
- Tests are self-contained and don't require external vault files
- Test runner script requires bash shell environment

## Troubleshooting

### Authentication Issues
```bash
# Set up password file
echo "your_vault_password" > ~/.ansible/vault_pass
chmod 600 ~/.ansible/vault_pass

# Configure in Neovim
let g:ansible_vault_password_file = '~/.ansible/vault_pass'
```

### Vault ID Configuration Issues

If you get "vault-ids default,default available" error:

```vim
" Option 1: Use password file only (recommended for single vault)
let g:ansible_vault_password_file = '~/.ansible/vault_pass'
" Don't set g:ansible_vault_identity

" Option 2: Use specific vault identity
let g:ansible_vault_identity = 'prod@~/.ansible/prod_pass'

" Option 3: Use interactive prompts for multiple vaults
" Use :VaultEncryptPrompt and :VaultDecryptPrompt commands
```

### Multiple Vault IDs
```vim
" For projects with multiple vault identities
let g:ansible_vault_identity = 'prod@~/.ansible/prod_pass'

" Or use the prompt commands for per-operation vault ID selection
:VaultEncryptPrompt
```

## Testing

The plugin includes a comprehensive test suite to ensure reliability and functionality.

### Running Tests

```bash
# Run all tests with coverage reporting
./test_runner.sh

# Quick validation test
nvim --headless -S tests/quick_test.lua

# Full integration test suite
nvim --headless -S tests/integration_test.lua
```

### Test Coverage

The test suite includes:

- **Integration Tests** (`tests/integration_test.lua`)
  - Module loading and API availability validation
  - Buffer operations and cursor positioning tests
  - Debug functionality verification
  - Error handling and edge case validation

- **Quick Validation** (`tests/quick_test.lua`)
  - Fast core functionality check
  - API structure verification
  - Critical function availability test

- **Test Infrastructure** (`test_runner.sh`)
  - Automated syntax validation for Lua and Vim files
  - Test coverage reporting (24 public functions, 16 local functions)
  - Support for CI/CD environments
  - Error-free execution with proper cleanup

### Test Results

Current test coverage includes:
- ✅ **Module integrity** - Plugin loads correctly with proper structure
- ✅ **API availability** - All 10+ critical functions accessible
- ✅ **Buffer handling** - Safe buffer operations and cursor management
- ✅ **Error resilience** - Graceful handling of edge cases and invalid input
- ✅ **Debug functionality** - Operational debugging and logging features

## Development

This plugin was developed using [Cursor](https://cursor.sh/) with [Claude](https://claude.ai/) AI assistance.

## License

MIT License