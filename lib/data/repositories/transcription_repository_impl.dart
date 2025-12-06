import '../../core/utils/error_handler.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/transcription_repository.dart';
import '../datasources/groq_transcription_remote_data_source.dart';

/// Implementation of transcription repository
class TranscriptionRepositoryImpl implements TranscriptionRepository {
  final GroqTranscriptionRemoteDataSource _remoteDataSource;

  TranscriptionRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<String>> transcribeAudio(String audioFilePath) async {
    try {
      Logger.info('TranscriptionRepository: Starting transcription for: $audioFilePath');
      final transcription = await _remoteDataSource.transcribeAudio(audioFilePath);
      Logger.info('TranscriptionRepository: Transcription successful');
      return Success(transcription);
    } catch (e, stackTrace) {
      Logger.error('TranscriptionRepository: Transcription failed', error: e, stackTrace: stackTrace);
      final failure = mapExceptionToFailure(e as Exception);
      Logger.error('TranscriptionRepository: Mapped to failure: ${failure.message}');
      return Error(failure);
    }
  }
}

