import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../entities/recording.dart';
import '../../repositories/recording_repository.dart';

/// Parameters for saving transcription and summary
class SaveTranscriptionAndSummaryParams {
  final String recordingId;
  final String transcription;
  final String summary;

  const SaveTranscriptionAndSummaryParams({
    required this.recordingId,
    required this.transcription,
    required this.summary,
  });
}

/// Use case for saving transcription and summary to recording
class SaveTranscriptionAndSummary implements UseCase<Recording, SaveTranscriptionAndSummaryParams> {
  final RecordingRepository _repository;

  SaveTranscriptionAndSummary(this._repository);

  @override
  Future<Result<Recording>> call(SaveTranscriptionAndSummaryParams params) async {
    // Get existing recording
    final getResult = await _repository.getRecordingById(params.recordingId);
    
    return getResult.fold(
      onSuccess: (recording) async {
        // Update recording with transcription and summary
        final updatedRecording = recording.copyWith(
          rawTranscription: params.transcription,
          summarizedTranscription: params.summary,
        );
        
        return await _repository.updateRecording(updatedRecording);
      },
      onError: (failure) => Error(failure),
    );
  }
}

