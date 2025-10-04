# Project Overview

## Purpose
A Flutter WebView application that manages browsing history with local storage using SharedPreferences.

## Tech Stack
- **Framework**: Flutter 3.0+
- **Language**: Dart
- **Key Dependencies**:
  - flutter_inappwebview: ^6.0.0 (WebView functionality)
  - shared_preferences: ^2.2.0 (Local storage)
  - provider: ^6.0.5 (State management)
  - go_router: ^12.0.0 (Navigation)
- **Dev Dependencies**:
  - flutter_test (Testing)
  - flutter_lints: ^2.0.0 (Linting)

## Project Structure
```
lib/
├── main.dart                           # Entry point
├── models/
│   └── recent_item.dart               # Data model for history items
└── repositories/
    └── history_repository.dart        # History management logic
```

## Current Status
- Basic Flutter app setup with MaterialApp
- RecentItem model with JSON serialization
- HistoryRepository with SharedPreferences integration
- History management: add, remove, clear (max 10 items)
