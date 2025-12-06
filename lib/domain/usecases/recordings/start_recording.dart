import '../../../../core/services/audio_recorder_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../../../core/utils/error_handler.dart';

/// Use case for starting audio recording
class StartRecording implements UseCaseNoParams<String> {
  final AudioRecorderService _recorderService;

  StartRecording(this._recorderService);

  @override
  Future<Result<String>> call() async {
    try {
      final filePath = await _recorderService.startRecording();
      return Success(filePath);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }
}

