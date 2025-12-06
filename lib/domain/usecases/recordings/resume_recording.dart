import '../../../../core/services/audio_recorder_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../../../core/utils/error_handler.dart';

/// Use case for resuming audio recording
class ResumeRecording implements UseCaseNoParams<void> {
  final AudioRecorderService _recorderService;

  ResumeRecording(this._recorderService);

  @override
  Future<Result<void>> call() async {
    try {
      await _recorderService.resumeRecording();
      return const Success(null);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }
}

