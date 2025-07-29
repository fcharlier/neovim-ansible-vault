# Changelog

## [1.0.1] - 2024-12-29

### Added
- Support for `yaml.ansible` filetype detection and auto-loading
- File type specific mappings for `yaml.ansible` files
- Updated lazy.nvim configuration to include `yaml.ansible`

### Changed
- Enhanced auto-detection to work with `yaml.ansible` filetype
- Updated documentation to reflect new filetype support

## [1.0.0] - 2024-12-29

### Added
- Complete Ansible Vault integration for Neovim
- Support for encrypt/decrypt operations on selections and ranges
- Full file encryption/decryption commands
- Vault viewing (read-only decrypt) functionality
- Interactive editing mode with auto-encrypt on save
- Vault file rekeying support
- Configurable password files and vault identities
- Auto-detection of Ansible vault files
- Operator mode support for text objects
- Comprehensive key mappings for all operations

### Features
- `:VaultEncrypt` - Encrypt selection or range
- `:VaultDecrypt` - Decrypt selection or range
- `:VaultView` - View decrypted content without modifying
- `:VaultEncryptFile` - Encrypt entire file
- `:VaultDecryptFile` - Decrypt entire file
- `:VaultEditFile` - Safe editing with auto-encrypt on save
- `:VaultRekey` - Change vault password/key
- `:VaultEncryptPrompt` - Interactive encrypt with vault ID
- `:VaultDecryptPrompt` - Interactive decrypt with vault ID

### Key Mappings
- `<leader>ve` - Encrypt (visual mode & operator mode)
- `<leader>vd` - Decrypt (visual mode & operator mode)
- `<leader>vv` - View decrypted content
- `<leader>vE` - Encrypt entire file
- `<leader>vD` - Decrypt entire file
- `<leader>vF` - Edit vault file safely
- `<leader>vR` - Rekey file

### Configuration
- `g:ansible_vault_password_file` - Set password file path
- `g:ansible_vault_identity` - Set vault identity
- `g:ansible_vault_no_mappings` - Disable default mappings

### Refactored From
- Previous generic command-replace plugin
- Now specialized specifically for ansible-vault operations
- Improved error handling and user experience
- Better integration with Ansible workflow patterns