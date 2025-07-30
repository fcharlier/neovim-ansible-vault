# Contributing to Neovim Ansible Vault Plugin

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## 🚀 **Quick Start**

1. **Fork and clone** the repository
2. **Install requirements**: Neovim 0.5+ and `ansible-vault` command
3. **Run tests** to ensure everything works: `./test_runner.sh`
4. **Make changes** following the guidelines below
5. **Submit a pull request** with description of changes

## 🧪 **Testing**

### Running Tests Locally
```bash
# Full test suite with coverage
./test_runner.sh

# Quick validation only
./test_runner.sh --syntax-only

# Individual test files
nvim --headless -S tests/integration_test.lua
nvim --headless -S tests/quick_test.lua
```

### Test Requirements
- All tests must pass before PR submission
- New features should include test coverage
- Integration tests validate real-world usage patterns
- No external dependencies required for testing

### CI/CD Pipeline
GitHub Actions automatically run:
- **Syntax validation** for Lua and Vim files
- **Integration tests** on Neovim stable and nightly
- **Code quality checks** and linting
- **Multi-platform compatibility** testing

## 📝 **Development Guidelines**

### Code Style
- Follow existing Lua coding patterns
- Use descriptive function and variable names
- Include inline documentation for complex logic
- Preserve YAML indentation and comment spacing

### Key Features to Maintain
- **Indentation preservation** in nested YAML structures
- **Comment spacing** (ensure space before `#` character)
- **Cursor-based operations** (`<leader>vc` functionality)
- **Public API stability** for existing functions

### Testing New Features
- Test with various YAML structures (nested, quoted, comments)
- Verify both encryption and decryption paths
- Test cursor positioning and selection handling
- Validate error handling for edge cases

## 🐛 **Bug Reports**

When reporting bugs, please include:
- Neovim version (`nvim --version`)
- Plugin version or commit hash
- Minimal reproduction case
- Expected vs actual behavior
- Any error messages

## 💡 **Feature Requests**

For new features:
- Explain the use case and benefit
- Consider backward compatibility
- Propose implementation approach
- Include example usage

## 📋 **Pull Request Process**

1. **Create feature branch** from `main`
2. **Implement changes** following guidelines
3. **Add/update tests** for new functionality
4. **Update documentation** (README, CHANGELOG)
5. **Run test suite** locally
6. **Submit PR** with detailed description
7. **Address review feedback** promptly

### PR Requirements
- [ ] All CI checks pass (automated)
- [ ] Tests demonstrate functionality
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
- [ ] Follows existing code patterns

## 🔧 **Development Setup**

### Local Environment
```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/neovim-ansible-vault.git
cd neovim-ansible-vault

# Verify setup
./test_runner.sh --syntax-only

# Test basic functionality
nvim test-file.yml
# Try <leader>vc on a YAML key-value pair
```

### Debugging
- Enable debug mode: `:VaultToggleDebug`
- View logs: `:VaultViewLog`
- Check function availability: `:lua print(vim.inspect(require('ansible-vault')))`

## 📊 **Code Coverage**

Current test coverage:
- **24 public functions** tested
- **Integration test suite** validates real usage
- **Multi-version compatibility** (Neovim stable + nightly)
- **Cross-platform testing** (Ubuntu, macOS, Windows)

## 🤝 **Community**

- **Be respectful** and constructive in discussions
- **Help others** with questions and issues
- **Share knowledge** and best practices
- **Follow the code of conduct**

## 📄 **License**

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to the Neovim Ansible Vault plugin! 🎉