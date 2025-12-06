import 'package:flutter_tts/flutter_tts.dart';
import '../utils/logger.dart';
import '../errors/exceptions.dart';

/// Text-to-Speech service wrapper around flutter_tts
class TtsService {
  final FlutterTts _tts;

  TtsService() : _tts = FlutterTts();

  Future<void> speak({
    required String text,
    String language = 'en-US',
    double rate = 0.9,
    double pitch = 1.0,
  }) async {
    try {
      Logger.info('TTS: speak start (lang: $language, rate: $rate, pitch: $pitch)');
      await _tts.setLanguage(language);
      await _tts.setSpeechRate(rate);
      await _tts.setPitch(pitch);
      await _tts.stop(); // ensure clean start
      final result = await _tts.speak(text);
      Logger.info('TTS: speak result -> $result');
    } catch (e, stack) {
      Logger.error('TTS: speak failed', error: e, stackTrace: stack);
      throw const AudioException('Failed to speak text');
    }
  }

  Future<void> stop() async {
    try {
      Logger.info('TTS: stop');
      await _tts.stop();
    } catch (e, stack) {
      Logger.error('TTS: stop failed', error: e, stackTrace: stack);
      throw const AudioException('Failed to stop speech');
    }
  }

  Future<void> pause() async {
    try {
      Logger.info('TTS: pause');
      await _tts.pause();
    } catch (e, stack) {
      Logger.error('TTS: pause failed', error: e, stackTrace: stack);
      throw const AudioException('Failed to pause speech');
    }
  }
}


