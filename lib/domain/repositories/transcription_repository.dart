/// Repository interface for transcription
abstract class TranscriptionRepository {
  Future<String> transcribeAudio(String audioFilePath);
}

