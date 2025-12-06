import '../../../core/utils/result.dart';
import '../../../core/utils/usecase.dart';
import '../../../core/services/tts_settings_service.dart';
import '../../entities/tts_settings.dart';

class SaveTtsSettingsParams {
  final TtsSettings settings;

  const SaveTtsSettingsParams(this.settings);
}

class SaveTtsSettings implements UseCase<void, SaveTtsSettingsParams> {
  final TtsSettingsService _service;

  SaveTtsSettings(this._service);

  @override
  Future<Result<void>> call(SaveTtsSettingsParams params) async {
    await _service.save(params.settings);
    return const Success(null);
  }
}


