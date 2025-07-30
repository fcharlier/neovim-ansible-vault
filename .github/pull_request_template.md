## Pull Request Checklist

Thank you for contributing to the Neovim Ansible Vault plugin! Please ensure your PR meets the following requirements:

### 🧪 **Testing**
- [ ] All tests pass locally (`./test_runner.sh`)
- [ ] Integration tests validate new functionality
- [ ] No syntax errors in Lua or Vim files
- [ ] Test coverage maintained or improved

### 📝 **Documentation**
- [ ] README updated if new features added
- [ ] CHANGELOG entry added for significant changes
- [ ] Example files updated if relevant
- [ ] Inline code documentation for new functions

### 🔧 **Code Quality**
- [ ] No debug print statements left in code
- [ ] Follows existing code style and patterns
- [ ] Preserves YAML indentation and comment spacing
- [ ] Error handling implemented for new features

### 🎯 **Functionality**
- [ ] New features work with nested YAML structures
- [ ] Cursor-based operations (`<leader>vc`) function correctly
- [ ] Both encryption and decryption paths tested
- [ ] No regression in existing functionality

### 📋 **Description**

**What does this PR do?**
<!-- Describe the changes in this PR -->

**Why is this change needed?**
<!-- Explain the problem this PR solves -->

**How was this tested?**
<!-- Describe how you verified the changes work -->

**Breaking changes?**
<!-- List any breaking changes or "None" -->

---

**Automated checks will run when you submit this PR:**
- ✅ Syntax validation for Lua and Vim files
- ✅ Integration test suite (24+ functions tested)
- ✅ Code quality checks
- ✅ Multi-version Neovim compatibility (stable + nightly)

The maintainers will review your PR once all checks pass. Thank you for contributing! 🎉