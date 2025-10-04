# Suggested Commands

## Development Commands

### Running the App
```bash
flutter run                 # Run on connected device/emulator
flutter run -d chrome      # Run on Chrome
flutter run -d macos       # Run on macOS
```

### Testing
```bash
flutter test               # Run all tests
flutter test test/path     # Run specific test file
```

### Code Quality
```bash
flutter analyze            # Run static analysis
dart format .              # Format all Dart files
dart format lib/           # Format specific directory
```

### Dependencies
```bash
flutter pub get            # Install dependencies
flutter pub upgrade        # Upgrade dependencies
flutter pub outdated       # Check for outdated packages
```

### Build
```bash
flutter build apk          # Build Android APK
flutter build ios          # Build iOS
flutter build macos        # Build macOS app
flutter build web          # Build web app
```

## Git Commands (Darwin/macOS)
```bash
git status                 # Check repository status
git add .                  # Stage all changes
git commit -m "message"    # Commit changes
git branch                 # List branches
git log --oneline         # View commit history
```

## Utility Commands (macOS)
```bash
ls -la                    # List files with details
find . -name "*.dart"     # Find Dart files
grep -r "pattern" lib/    # Search in files
open -a Simulator         # Open iOS Simulator
```
