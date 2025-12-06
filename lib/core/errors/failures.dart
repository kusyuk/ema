import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Permission failure
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Audio recording failure
class AudioFailure extends Failure {
  const AudioFailure(super.message);
}

/// Transcription failure
class TranscriptionFailure extends Failure {
  const TranscriptionFailure(super.message);
}

/// Summarization failure
class SummarizationFailure extends Failure {
  const SummarizationFailure(super.message);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

