import '../../../core/utils/result.dart';
import '../../../core/utils/usecase.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/services/tts_service.dart';

class SpeakTextParams {
  final String text;
  final String language;
  final double rate;
  final double pitch;

  const SpeakTextParams({
    required this.text,
    this.language = 'en-US',
    this.rate = 0.9,
    this.pitch = 1.0,
  });
}

class SpeakText implements UseCase<void, SpeakTextParams> {
  final TtsService _service;

  SpeakText(this._service);

  @override
  Future<Result<void>> call(SpeakTextParams params) async {
    try {
      await _service.speak(
        text: params.text,
        language: params.language,
        rate: params.rate,
        pitch: params.pitch,
      );
      return const Success(null);
    } on AppException catch (e) {
      return Error(mapExceptionToFailure(e));
    } catch (e) {
      return Error(AudioFailure('Failed to speak text: ${e.toString()}'));
    }
  }
}


