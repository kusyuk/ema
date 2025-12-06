import '../../core/utils/result.dart';

/// Repository interface for transcription
abstract class TranscriptionRepository {
  Future<Result<String>> transcribeAudio(String audioFilePath);
}

