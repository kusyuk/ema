/// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => message;
}

/// Server exception
class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

/// Cache exception
class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

/// Permission exception
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

/// Audio recording exception
class AudioException extends AppException {
  const AudioException(super.message, {super.code});
}

/// Transcription exception
class TranscriptionException extends AppException {
  const TranscriptionException(super.message, {super.code});
}

/// Summarization exception
class SummarizationException extends AppException {
  const SummarizationException(super.message, {super.code});
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

