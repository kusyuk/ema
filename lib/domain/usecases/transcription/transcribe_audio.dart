import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../repositories/transcription_repository.dart';

/// Parameters for transcribing audio
class TranscribeAudioParams {
  final String audioFilePath;

  const TranscribeAudioParams(this.audioFilePath);
}

/// Use case for transcribing audio
class TranscribeAudio implements UseCase<String, TranscribeAudioParams> {
  final TranscriptionRepository _repository;

  TranscribeAudio(this._repository);

  @override
  Future<Result<String>> call(TranscribeAudioParams params) async {
    return await _repository.transcribeAudio(params.audioFilePath);
  }
}

