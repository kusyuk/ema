import '../../../../core/services/audio_recorder_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../../../core/utils/error_handler.dart';

/// Use case for stopping audio recording
class StopRecording implements UseCaseNoParams<String?> {
  final AudioRecorderService _recorderService;

  StopRecording(this._recorderService);

  @override
  Future<Result<String?>> call() async {
    try {
      final filePath = await _recorderService.stopRecording();
      return Success(filePath);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }
}

