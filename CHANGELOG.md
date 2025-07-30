# Changelog

## [1.1.4] - 2025-07-30

### Added
- **GitHub Actions CI/CD pipeline for automated testing and validation**
  - Added `.github/workflows/test.yml` - Comprehensive test suite running on Neovim stable and nightly
  - Added `.github/workflows/lint.yml` - Code quality checks, syntax validation, and structure verification
  - Multi-version compatibility testing ensures plugin works across Neovim versions
  - Automated syntax validation for Lua and Vim files on every PR
  - Integration test execution with 24+ function coverage validation
  - README structure validation and examples directory verification
- **Contributor and maintainer tools**
  - Added `.github/pull_request_template.md` - Structured PR guidelines with testing checklist
  - Added `.github/CONTRIBUTING.md` - Comprehensive development guide and contribution workflow
  - Clear testing requirements and code quality standards
  - Automated artifact collection for debugging failed tests

### Enhanced
- **Development workflow automation**
  - Pull requests automatically validated before merge
  - Code quality gates prevent debug statements and syntax errors
  - Multi-platform testing ensures broad compatibility
  - Clear feedback loop for contributors with detailed check descriptions

## [1.1.3] - 2025-07-30

### Added
- **Comprehensive test suite for major plugin features**
  - Added `tests/integration_test.lua` - Full integration test coverage for all public APIs
  - Added `tests/quick_test.lua` - Fast validation test for core functionality
  - Added `test_runner.sh` - Automated test runner with syntax validation and coverage reporting
  - Tests cover: module loading, API availability, buffer operations, cursor functionality, debug features
- **Test infrastructure and CI support**
  - Automated syntax validation for Lua and Vim files
  - Test coverage reporting (24 public functions, 16 local functions)
  - Error-free test execution with proper error handling
  - Support for both standalone and CI environments

### Enhanced
- **Plugin reliability and maintenance**
  - Added comprehensive error handling validation
  - Verified all critical functions are accessible and functional
  - Added buffer operation safety tests
  - Enhanced debug functionality validation

## [1.1.2] - 2025-07-30

### Fixed
- **CRITICAL: Fixed indentation loss in nested YAML structures**
  - Cursor-based operations (`<leader>vc`) now preserve original YAML indentation
  - Fixed `decrypt_yaml_value()` and `encrypt_yaml_value()` to maintain leading whitespace
  - Nested structures like `environments.production.database.password` maintain proper spacing
- **Fixed invalid YAML output due to comment spacing**
  - Added `ensure_comment_spacing()` helper to guarantee proper spacing before `#` comments
  - All reconstruction functions now ensure at least one space before inline comments
  - Prevents invalid YAML like `password: "value"#comment` → generates `password: "value" #comment`
- **Improved vault encryption detection logic**
  - `smart_at_cursor()` now correctly detects encryption status of YAML values (not entire structures)
  - Fixed false positives where `!vault` indicator in structure was mistaken for encrypted content
  - Cursor-based encrypt/decrypt now works reliably with nested vault content

### Enhanced
- Updated nested examples file with comprehensive test cases for indentation and comment preservation
- Added comment spacing validation examples to demonstrate proper YAML formatting

## [1.1.1] - 2025-07-29

### Fixed
- **CRITICAL: VaultEditFile now correctly saves files encrypted**
  - Fixed `encrypt_on_save()` to use file-based encryption instead of stdin/stdout
  - File is now properly encrypted in place and reloaded
  - Auto-command is properly cleaned up after encryption
- **CRITICAL: Fixed <leader>vc and all decrypt operations**
  - Fixed stdin issue in `execute_vault_command` that broke all decrypt functions
  - Replaced `jobstart` with `vim.fn.system()` for proper stdin/stdout handling
  - Fixed: `M.decrypt()`, `M.decrypt_prompt()`, `M.decrypt_operator()`, `M.decrypt_yaml_value()`
  - Fixed: `M.encrypt()`, `M.encrypt_operator()`
  - Cursor-based operations (`<leader>vc`) now work correctly again

### Changed
- **VaultEditFile behavior: save-triggered encryption**
  - `:VaultEditFile` decrypts buffer content while file stays encrypted on disk
  - `:w` encrypts current buffer content to disk but keeps buffer decrypted
  - No continuous auto-encryption - only encrypts when explicitly saving
  - Perfect for controlled editing with security when ready
  - Added `:VaultStopAutoEncrypt` to stop save-triggered encryption

## [1.1.0] - 2025-07-29

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

## [1.0.3] - 2025-07-29

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

## [1.0.2] - 2025-07-29

### Fixed
- Fixed visual mode error when trying to decrypt non-encrypted content
- Added content validation for all encrypt/decrypt operations
- Better error messages for invalid operations (encrypt already encrypted content, decrypt plain text)

### Added
- Content validation functions to check if text is vault-encrypted
- Proper error handling for mismatched operations

## [1.0.1] - 2025-07-29

### Added
- Support for `yaml.ansible` filetype detection and auto-loading
- File type specific mappings for `yaml.ansible` files
- Updated lazy.nvim configuration to include `yaml.ansible`

### Changed
- Enhanced auto-detection to work with `yaml.ansible` filetype
- Updated documentation to reflect new filetype support

## [1.0.0] - 2025-07-29

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