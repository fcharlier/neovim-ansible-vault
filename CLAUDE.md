# Claude AI Assistant Guide for Neovim Ansible Vault Plugin

This document helps Claude AI understand the project structure and common development tasks.

## 📁 Project Overview

**Neovim Ansible Vault Plugin** - Provides seamless ansible-vault encryption/decryption within Neovim with YAML-aware operations.

### Key Files Structure
```
neovim-ansible-vault/
├── lua/ansible-vault.lua           # Core plugin logic (Lua)
├── plugin/ansible-vault.vim        # Neovim commands & mappings (Vimscript)
├── tests/
│   ├── integration_test.lua        # Comprehensive API testing
│   ├── quick_test.lua             # Fast core functionality tests
│   └── test_runner.sh             # Automated test execution script
├── examples/
│   ├── nested-examples.yml        # Test cases for nested YAML structures
│   ├── test-vault.yml             # Basic vault examples
│   └── yaml-test.yml              # YAML parsing test cases
├── .github/workflows/
│   ├── test.yml                   # CI: Multi-version testing (stable+nightly)
│   └── lint.yml                   # CI: Code quality & syntax validation
├── .github/
│   ├── pull_request_template.md   # PR checklist and guidelines
│   └── CONTRIBUTING.md            # Developer contribution guide
├── README.md                      # Main documentation
├── CHANGELOG.md                   # Version history and changes
└── CLAUDE.md                      # This file
```

## 🧪 Running Tests

### Local Testing
```bash
# Full test suite with coverage
./test_runner.sh

# Syntax validation only
./test_runner.sh --syntax-only

# Coverage check only
./test_runner.sh --coverage-only

# Individual test files
nvim --headless -c "set runtimepath+=$PWD" -S tests/integration_test.lua
nvim --headless -c "set runtimepath+=$PWD" -S tests/quick_test.lua
```

### Test Environment Requirements
- **Neovim 0.5+** (stable or nightly)
- **ansible-vault binary** (`sudo apt install ansible` on Ubuntu)
- **Plugin in runtime path** (use `-c "set runtimepath+=$PWD"` for testing)

### CI/CD Testing
- **GitHub Actions** automatically run on PRs
- **Multi-version testing**: Neovim stable + nightly
- **Complete environment**: Neovim + ansible-vault + plugin setup
- **Quality gates**: Syntax, integration tests, code standards

## 📝 Updating README.md

### Structure to Maintain
```markdown
# Neovim Ansible Vault Plugin
## Features                    # List of capabilities
## Installation               # Setup instructions
## Usage                      # Commands and key mappings
## Configuration             # Settings and options
## Examples                  # Real-world usage
## Requirements              # Dependencies
## Testing                   # How to run tests
## Troubleshooting           # Common issues
## Contributing              # Development guide
## License                   # MIT license info
```

### Key Sections to Update When Adding Features
1. **Features section** - Add new capabilities
2. **Usage section** - Document new commands/mappings
3. **Configuration section** - Add new options
4. **Testing section** - Update test coverage info
5. **Examples** - Add usage examples for new features

### Testing-Related Content Location
- **Line ~335-381**: Main "Testing" section
- **Line ~298-304**: "Testing Requirements (Optional)" subsection
- **Line ~23**: "Comprehensive testing" in Features list

## 📋 Updating CHANGELOG.md

### Version Format
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features and capabilities

### Fixed
- Bug fixes and issue resolutions

### Changed
- Modified behavior or improvements

### Enhanced
- Performance or usability improvements
```

### Current Version Tracking
- **Latest**: Check first entry in CHANGELOG.md
- **Pattern**: Semantic versioning (major.minor.patch)
- **Date**: Always use format YYYY-MM-DD

### When to Bump Versions
- **Patch (X.Y.Z+1)**: Bug fixes, minor improvements
- **Minor (X.Y+1.0)**: New features, backward compatible
- **Major (X+1.0.0)**: Breaking changes

### Common Change Categories
```markdown
### Added
- New commands, functions, or features
- New configuration options
- New examples or documentation

### Fixed
- CRITICAL: [Issue] - Major functionality fixes
- Bug fixes with specific issue references
- CI/testing improvements

### Enhanced
- Performance improvements
- Better error handling
- Improved user experience
```

## 🔧 Core Plugin Functionality

### Main Functions (lua/ansible-vault.lua)
- **M.encrypt()** - Encrypt selection/range
- **M.decrypt()** - Decrypt selection/range
- **M.encrypt_yaml_value()** - YAML-aware value encryption
- **M.decrypt_yaml_value()** - YAML-aware value decryption
- **M.smart_at_cursor()** - Auto-detect encrypt/decrypt
- **M.toggle_debug()** - Debug mode toggle

### Key Implementation Details
- **YAML parsing**: Preserves indentation and comments
- **Comment spacing**: Ensures space before `#` character
- **Error handling**: Uses `vim.api.nvim_echo` for user feedback
- **Debug logging**: Writes to `~/.config/nvim/ansible-vault-debug.log`

## 🚀 Development Workflow

### 🚨 CRITICAL REMINDER

**ALWAYS add "Generated-by: Claude AI <claude@anthropic.com>" to every commit message!**

### Making Changes
1. **Create feature branch**: `git checkout -b feature/description`
2. **Run tests locally**: `./test_runner.sh`
3. **Update documentation**: README.md + CHANGELOG.md
4. **Commit with template**:
   ```
   type: Brief description

   - Detailed change 1
   - Detailed change 2

   Generated-by: Claude AI <claude@anthropic.com>
   ```


   **⚠️ IMPORTANT**: Always include the "Generated-by" trailer in ALL commits!

5. **Push and create PR**: GitHub Actions will validate

### Common Development Tasks
```bash
# Test specific functionality
nvim examples/nested-examples.yml  # Test with real YAML

# Validate syntax
nvim --headless -c "luafile lua/ansible-vault.lua" -c "qa"

# Debug mode
nvim -c ":VaultToggleDebug" # Enable debug logging

# Check logs
tail -f ~/.config/nvim/ansible-vault-debug.log
```

### GitHub Actions Validation
- **Automatic testing** on PR creation/updates
- **Multi-version compatibility** (Neovim stable + nightly)
- **Quality checks**: Syntax, tests, code standards
- **Required for merge**: All CI checks must pass

## 🐛 Common Issues & Solutions

### Test Failures
- **"Could not load ansible-vault module"**: Missing runtime path
  - Solution: Use `-c "set runtimepath+=$PWD"`
- **ansible-vault command not found**: Missing binary
  - Solution: `sudo apt install ansible`

### Plugin Issues
- **Indentation lost**: Check YAML parsing logic
- **Invalid YAML output**: Verify comment spacing
- **Commands not working**: Check plugin/ansible-vault.vim mappings

### Development Tips
- **Test with nested YAML**: Use `examples/nested-examples.yml`
- **Debug failures**: Enable debug mode and check logs
- **Validate changes**: Run full test suite before committing
- **Documentation**: Update README and CHANGELOG for all changes

## 📊 Test Coverage Information

### Current Coverage
- **24 public functions** tested in integration tests
- **16 local functions** in core module
- **2 main test files**: integration_test.lua + quick_test.lua
- **GitHub Actions**: Multi-environment validation

### Test Philosophy
- **Integration tests**: Test public API and real-world usage
- **No unit tests**: Focus on functional behavior over internals
- **Real environment**: Tests run with actual Neovim + ansible-vault

---

**Generated by Claude AI for efficient future assistance with this codebase.**