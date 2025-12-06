import '../errors/exceptions.dart';
import '../errors/failures.dart';

/// Convert exceptions to failures
Failure mapExceptionToFailure(Exception exception) {
  if (exception is ServerException) {
    return ServerFailure(exception.message);
  } else if (exception is NetworkException) {
    return NetworkFailure(exception.message);
  } else if (exception is CacheException) {
    return CacheFailure(exception.message);
  } else if (exception is PermissionException) {
    return PermissionFailure(exception.message);
  } else if (exception is AudioException) {
    return AudioFailure(exception.message);
  } else if (exception is TranscriptionException) {
    return TranscriptionFailure(exception.message);
  } else if (exception is SummarizationException) {
    return SummarizationFailure(exception.message);
  } else if (exception is ValidationException) {
    return ValidationFailure(exception.message);
  } else {
    return ServerFailure('An unexpected error occurred: ${exception.toString()}');
  }
}

