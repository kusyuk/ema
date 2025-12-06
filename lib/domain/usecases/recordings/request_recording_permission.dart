import '../../../../core/services/audio_recorder_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../../../core/utils/error_handler.dart';

/// Use case for requesting recording permission
class RequestRecordingPermission implements UseCaseNoParams<bool> {
  final AudioRecorderService _recorderService;

  RequestRecordingPermission(this._recorderService);

  @override
  Future<Result<bool>> call() async {
    try {
      final hasPermission = await _recorderService.requestPermission();
      return Success(hasPermission);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }
}

