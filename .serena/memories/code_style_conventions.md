# Code Style & Conventions

## Naming Conventions
- **Classes**: PascalCase (e.g., `RecentItem`, `HistoryRepository`)
- **Variables/Functions**: camelCase (e.g., `baseUrl`, `lastOpenedAt`, `getRecentItems`)
- **Constants**: camelCase with underscore prefix for private (e.g., `_historyKey`, `_maxHistorySize`)
- **Files**: snake_case (e.g., `recent_item.dart`, `history_repository.dart`)

## Code Patterns
- **Immutability**: Use `final` for class properties
- **Constructor**: Named parameters with `required` keyword
- **JSON Serialization**: Factory constructors (`fromJson`) and instance methods (`toJson`)
- **Equality**: Override `==` operator and `hashCode` for value comparison
- **Error Handling**: Try-catch blocks with fallback values (return empty list on error)
- **Async/Await**: Use `Future<T>` for async operations
- **Dependency Injection**: Constructor-based DI (e.g., `HistoryRepository(_prefs)`)

## Widget Patterns
- **StatelessWidget**: Use `const` constructors when possible
- **Material Design 3**: `useMaterial3: true`
- **Key Parameter**: Always include `super.key` in widget constructors

## File Organization
- Models in `lib/models/`
- Repositories/Data layer in `lib/repositories/`
- One class per file
- Import order: Dart SDK → Flutter → Third-party → Local
