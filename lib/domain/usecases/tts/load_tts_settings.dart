import '../../../core/utils/result.dart';
import '../../../core/utils/usecase.dart';
import '../../../core/services/tts_settings_service.dart';
import '../../entities/tts_settings.dart';

class LoadTtsSettings implements UseCase<TtsSettings, NoParams> {
  final TtsSettingsService _service;

  LoadTtsSettings(this._service);

  @override
  Future<Result<TtsSettings>> call(NoParams params) async {
    final settings = await _service.load();
    return Success(settings);
  }
}


