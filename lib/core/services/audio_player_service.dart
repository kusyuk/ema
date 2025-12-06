import 'package:just_audio/just_audio.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';

/// Audio player service
class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  String? _currentFilePath;

  /// Stream of playback position
  Stream<Duration> get positionStream => _player.positionStream;

  /// Stream of duration
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Stream of player state
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Current playback position
  Duration get position => _player.position;

  /// Current audio duration
  Duration? get duration => _player.duration;

  /// Check if playing
  bool get isPlaying => _player.playing;

  /// Check if paused
  bool get isPaused => _player.playerState.processingState == ProcessingState.ready &&
      _player.playerState.playing == false;

  /// Current file path
  String? get currentFilePath => _currentFilePath;

  /// Load audio file
  Future<void> loadAudio(String filePath) async {
    try {
      _currentFilePath = filePath;
      await _player.setFilePath(filePath);
      Logger.info('Audio loaded: $filePath');
    } catch (e) {
      Logger.error('Failed to load audio', error: e);
      throw AudioException('Failed to load audio file: ${e.toString()}');
    }
  }

  /// Play audio
  Future<void> play() async {
    try {
      await _player.play();
      Logger.info('Audio playback started');
    } catch (e) {
      Logger.error('Failed to play audio', error: e);
      throw AudioException('Failed to play audio: ${e.toString()}');
    }
  }

  /// Pause audio
  Future<void> pause() async {
    try {
      await _player.pause();
      Logger.info('Audio playback paused');
    } catch (e) {
      Logger.error('Failed to pause audio', error: e);
      throw AudioException('Failed to pause audio: ${e.toString()}');
    }
  }

  /// Stop audio
  Future<void> stop() async {
    try {
      await _player.stop();
      Logger.info('Audio playback stopped');
    } catch (e) {
      Logger.error('Failed to stop audio', error: e);
      throw AudioException('Failed to stop audio: ${e.toString()}');
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
      Logger.info('Audio seeked to: $position');
    } catch (e) {
      Logger.error('Failed to seek audio', error: e);
      throw AudioException('Failed to seek audio: ${e.toString()}');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      Logger.error('Failed to set volume', error: e);
      throw AudioException('Failed to set volume: ${e.toString()}');
    }
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    try {
      await _player.setSpeed(speed.clamp(0.25, 2.0));
    } catch (e) {
      Logger.error('Failed to set playback speed', error: e);
      throw AudioException('Failed to set playback speed: ${e.toString()}');
    }
  }

  /// Dispose resources
  void dispose() {
    _player.dispose();
    _currentFilePath = null;
  }
}

