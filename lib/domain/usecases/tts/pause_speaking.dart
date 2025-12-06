import '../../../core/utils/result.dart';
import '../../../core/utils/usecase.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/services/tts_service.dart';

class PauseSpeaking implements UseCase<void, NoParams> {
  final TtsService _service;

  PauseSpeaking(this._service);

  @override
  Future<Result<void>> call(NoParams params) async {
    try {
      await _service.pause();
      return const Success(null);
    } on AppException catch (e) {
      return Error(mapExceptionToFailure(e));
    } catch (e) {
      return Error(AudioFailure('Failed to pause speaking: ${e.toString()}'));
    }
  }
}


