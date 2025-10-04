# Task Completion Checklist

## After Completing Any Task

### 1. Code Quality
- [ ] Run `dart format .` to format code
- [ ] Run `flutter analyze` to check for issues
- [ ] Fix any warnings or errors

### 2. Testing
- [ ] Run `flutter test` to ensure tests pass
- [ ] Add tests for new functionality if applicable

### 3. Version Control
- [ ] Review changes with `git diff`
- [ ] Stage relevant files with `git add`
- [ ] Commit with descriptive message
- [ ] Check `git status` to verify clean state

### 4. Documentation
- [ ] Update comments for complex logic
- [ ] Update README if public API changes
- [ ] Document new dependencies in pubspec.yaml

### 5. Verification
- [ ] Run the app to verify changes work
- [ ] Test on target platform (iOS/Android/Web)
- [ ] Verify no console errors or warnings

## Common Issues to Check
- Null safety compliance
- Proper error handling
- Resource cleanup (dispose methods)
- Memory leaks in StatefulWidgets
