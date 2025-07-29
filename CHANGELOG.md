# Changelog

## [1.1.0] - 2024-12-29

### Added
- **YAML-aware encryption/decryption** - Smart handling of key-value pairs
- `:VaultEncryptValue` / `:VaultDecryptValue` - Encrypt/decrypt only YAML values
- `:VaultEncryptSmart` / `:VaultDecryptSmart` - Auto-detect YAML with user prompt
- New key mappings for YAML-specific operations
- Enhanced YAML parsing with support for quoted/unquoted values and comments
- Smart reconstruction of YAML lines preserving structure

### Changed
- Default `<leader>ve` and `<leader>vd` now use smart mode (auto-detects YAML)
- Added `<leader>vev` / `<leader>vdv` for YAML value-only operations
- Added `<leader>vef` / `<leader>vdf` for full-selection operations

## [1.0.3] - 2024-12-29

### Fixed
- Fixed "vault-ids default,default available" error by properly specifying --encrypt-vault-id
- Enhanced vault ID handling for encrypt operations
- Interactive encrypt prompt now correctly handles vault IDs
- Better error display with persistent messages

### Added
- Debug mode with :VaultToggleDebug command
- Enhanced error handling with nvim_echo for better visibility
- Debug test file for troubleshooting
- Documentation for vault ID configuration issues

## [1.0.2] - 2024-12-29

### Fixed
- Fixed visual mode error when trying to decrypt non-encrypted content
- Added content validation for all encrypt/decrypt operations
- Better error messages for invalid operations (encrypt already encrypted content, decrypt plain text)

### Added
- Content validation functions to check if text is vault-encrypted
- Proper error handling for mismatched operations

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

- Interactive editing mode with auto-encrypt on save
- Vault file rekeying support
- Configurable password files and vault identities
- Auto-detection of Ansible vault files
- Operator mode support for text objects
- Comprehensive key mappings for all operations

### Features
- `:VaultEncrypt` - Encrypt selection or range
- `:VaultDecrypt` - Decrypt selection or range

- `:VaultEncryptFile` - Encrypt entire file
- `:VaultDecryptFile` - Decrypt entire file
- `:VaultEditFile` - Safe editing with auto-encrypt on save
- `:VaultRekey` - Change vault password/key
- `:VaultEncryptPrompt` - Interactive encrypt with vault ID
- `:VaultDecryptPrompt` - Interactive decrypt with vault ID

### Key Mappings
- `<leader>ve` - Encrypt (visual mode & operator mode)
- `<leader>vd` - Decrypt (visual mode & operator mode)

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