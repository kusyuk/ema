import '../errors/failures.dart';

/// Result class for handling success/failure states
sealed class Result<T> {
  const Result();
}

/// Success result
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
}

/// Failure result
class Error<T> extends Result<T> {
  final Failure failure;
  
  const Error(this.failure);
}

/// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  /// Check if result is success
  bool get isSuccess => this is Success<T>;
  
  /// Check if result is error
  bool get isError => this is Error<T>;
  
  /// Get data if success, null otherwise
  T? get dataOrNull => switch (this) {
    Success(data: final data) => data,
    Error() => null,
  };
  
  /// Get failure if error, null otherwise
  Failure? get failureOrNull => switch (this) {
    Success() => null,
    Error(failure: final failure) => failure,
  };
  
  /// Fold result to a single value
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    return switch (this) {
      Success(data: final data) => onSuccess(data),
      Error(failure: final failure) => onError(failure),
    };
  }
}

