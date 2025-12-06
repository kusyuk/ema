import '../../../../core/services/audio_recorder_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../../../core/utils/error_handler.dart';

/// Use case for checking recording permission
class CheckRecordingPermission implements UseCaseNoParams<bool> {
  final AudioRecorderService _recorderService;

  CheckRecordingPermission(this._recorderService);

  @override
  Future<Result<bool>> call() async {
    try {
      final hasPermission = await _recorderService.hasPermission();
      return Success(hasPermission);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }
}

