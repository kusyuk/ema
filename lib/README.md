# EMA Project Structure

This project follows **Clean Architecture** principles with clear separation of concerns.

## Directory Structure

```
lib/
├── core/                    # Core functionality shared across the app
│   ├── constants/           # App-wide constants
│   │   ├── app_constants.dart
│   │   └── env_constants.dart
│   ├── di/                  # Dependency injection
│   │   └── injection_container.dart
│   ├── errors/              # Error handling
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/             # Network layer
│   │   └── api_client.dart
│   └── utils/               # Utility classes
│       ├── error_handler.dart
│       ├── logger.dart
│       ├── result.dart
│       ├── typedefs.dart
│       ├── usecase.dart
│       └── validators.dart
│
├── data/                    # Data layer
│   ├── datasources/        # Data sources (local/remote)
│   ├── models/            # Data models
│   └── repositories/       # Repository implementations
│
├── domain/                  # Domain layer (business logic)
│   ├── entities/           # Domain entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Use cases
│
├── features/                # Feature modules
│   └── (features will be added here)
│
├── presentation/            # Presentation layer (UI)
│   ├── pages/              # Screen widgets
│   ├── providers/          # State management
│   └── widgets/            # Reusable widgets
│
└── main.dart               # App entry point
```

## Architecture Layers

### 1. **Core Layer**
Contains shared functionality:
- Constants and configuration
- Error handling (exceptions and failures)
- Network client with error handling
- Dependency injection setup
- Utility classes (validators, logger, result wrapper)

### 2. **Domain Layer**
Business logic layer (independent of frameworks):
- **Entities**: Pure Dart classes representing business objects
- **Repositories**: Interfaces defining data operations
- **Use Cases**: Business logic operations

### 3. **Data Layer**
Data management:
- **Data Sources**: Local (Hive) and remote (API) data sources
- **Models**: Data transfer objects with JSON serialization
- **Repositories**: Implementation of domain repository interfaces

### 4. **Presentation Layer**
UI and state management:
- **Pages**: Screen widgets
- **Widgets**: Reusable UI components
- **Providers**: State management (using Provider package)

## Key Concepts

### Result Pattern
The app uses a `Result<T>` type to handle success/failure states:
```dart
Result<User> result = await getUserUseCase(userId);
result.fold(
  onSuccess: (user) => print(user.name),
  onError: (failure) => print(failure.message),
);
```

### Error Handling
- **Exceptions**: Thrown in data layer
- **Failures**: Used in domain/presentation layers
- Automatic conversion via `mapExceptionToFailure()`

### Dependency Injection
Using `get_it` for dependency injection. All dependencies are registered in `lib/core/di/injection_container.dart`.

## Development Guidelines

1. **Follow Clean Architecture**: Keep layers independent
2. **Use Result Pattern**: For all async operations that can fail
3. **Error Handling**: Convert exceptions to failures at repository boundaries
4. **State Management**: Use Provider for state management
5. **Code Style**: Follow Flutter/Dart style guide and linting rules

