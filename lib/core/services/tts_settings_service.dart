import 'package:hive/hive.dart';
import '../utils/logger.dart';
import '../../domain/entities/tts_settings.dart';

class TtsSettingsService {
  static const _languageKey = 'tts_language';
  static const _rateKey = 'tts_rate';
  static const _pitchKey = 'tts_pitch';

  final Box<dynamic> _box;

  TtsSettingsService(this._box);

  Future<TtsSettings> load() async {
    try {
      final language = _box.get(_languageKey, defaultValue: TtsSettings.defaults.language) as String;
      final rate = (_box.get(_rateKey, defaultValue: TtsSettings.defaults.rate) as num).toDouble();
      final pitch = (_box.get(_pitchKey, defaultValue: TtsSettings.defaults.pitch) as num).toDouble();
      final settings = TtsSettings(language: language, rate: rate, pitch: pitch);
      Logger.info('TTS settings loaded: $settings');
      return settings;
    } catch (e, stack) {
      Logger.error('Failed to load TTS settings', error: e, stackTrace: stack);
      return TtsSettings.defaults;
    }
  }

  Future<void> save(TtsSettings settings) async {
    try {
      await _box.put(_languageKey, settings.language);
      await _box.put(_rateKey, settings.rate);
      await _box.put(_pitchKey, settings.pitch);
      Logger.info('TTS settings saved: ${settings.toMap()}');
    } catch (e, stack) {
      Logger.error('Failed to save TTS settings', error: e, stackTrace: stack);
    }
  }
}


