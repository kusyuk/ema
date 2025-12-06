import '../../../core/utils/result.dart';
import '../../../core/utils/usecase.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/services/tts_service.dart';

class StopSpeaking implements UseCase<void, NoParams> {
  final TtsService _service;

  StopSpeaking(this._service);

  @override
  Future<Result<void>> call(NoParams params) async {
    try {
      await _service.stop();
      return const Success(null);
    } on AppException catch (e) {
      return Error(mapExceptionToFailure(e));
    } catch (e) {
      return Error(AudioFailure('Failed to stop speaking: ${e.toString()}'));
    }
  }
}


