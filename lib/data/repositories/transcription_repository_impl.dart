import '../../core/utils/error_handler.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/transcription_repository.dart';
import '../datasources/elevenlabs_remote_data_source.dart';

/// Implementation of transcription repository
class TranscriptionRepositoryImpl implements TranscriptionRepository {
  final ElevenLabsRemoteDataSource _remoteDataSource;

  TranscriptionRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<String>> transcribeAudio(String audioFilePath) async {
    try {
      final transcription = await _remoteDataSource.transcribeAudio(audioFilePath);
      return Success(transcription);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }
}

