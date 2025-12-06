import 'dart:async';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../utils/file_storage.dart';
import '../utils/logger.dart';

/// Audio recording service
class AudioRecorderService {
  final AudioRecorder _recorder;
  String? _currentRecordingPath;
  Timer? _durationTimer;
  Duration _currentDuration = Duration.zero;
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();

  AudioRecorderService() : _recorder = AudioRecorder();

  /// Stream of recording duration updates
  Stream<Duration> get durationStream => _durationController.stream;

  /// Current recording duration
  Duration get currentDuration => _currentDuration;

  /// Check if currently recording
  Future<bool> isRecording() => _recorder.isRecording();

  /// Check if permission is granted
  Future<bool> hasPermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      Logger.error('Failed to check recording permission', error: e);
      return false;
    }
  }

  /// Request recording permission
  Future<bool> requestPermission() async {
    try {
      // First check if already granted
      if (await hasPermission()) {
        return true;
      }
      
      // Request permission using permission_handler
      final status = await Permission.microphone.request();
      
      if (status.isGranted) {
        Logger.info('Microphone permission granted');
        return true;
      } else if (status.isPermanentlyDenied) {
        Logger.warning('Microphone permission permanently denied');
        throw const PermissionException(
          'Microphone permission is permanently denied. Please enable it in app settings.',
        );
      } else {
        Logger.warning('Microphone permission denied');
        return false;
      }
    } catch (e) {
      Logger.error('Failed to request recording permission', error: e);
      if (e is PermissionException) rethrow;
      throw PermissionException('Failed to request microphone permission: ${e.toString()}');
    }
  }

  /// Start recording
  Future<String> startRecording() async {
    try {
      if (await isRecording()) {
        throw const AudioException('Recording is already in progress');
      }

      // Check permission
      if (!await hasPermission()) {
        final granted = await requestPermission();
        if (!granted) {
          throw const PermissionException('Microphone permission not granted');
        }
      }

      // Generate file name
      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final filePath = FileStorage.getAudioFilePath(fileName);

      // Configure recording settings
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: AppConstants.defaultBitRate,
        sampleRate: AppConstants.defaultSampleRate,
      );

      // Start recording
      await _recorder.start(
        config,
        path: filePath,
      );

      _currentRecordingPath = filePath;
      _currentDuration = Duration.zero;
      _startDurationTimer();

      Logger.info('Recording started: $filePath');
      return filePath;
    } catch (e) {
      Logger.error('Failed to start recording', error: e);
      if (e is AppException) rethrow;
      throw AudioException('Failed to start recording: ${e.toString()}');
    }
  }

  /// Stop recording
  Future<String?> stopRecording() async {
    try {
      if (!await isRecording()) {
        throw const AudioException('No recording in progress');
      }

      final path = await _recorder.stop();
      _stopDurationTimer();
      
      final savedPath = _currentRecordingPath;
      _currentRecordingPath = null;
      _currentDuration = Duration.zero;

      Logger.info('Recording stopped: $path');
      return savedPath;
    } catch (e) {
      Logger.error('Failed to stop recording', error: e);
      _stopDurationTimer();
      _currentRecordingPath = null;
      if (e is AppException) rethrow;
      throw AudioException('Failed to stop recording: ${e.toString()}');
    }
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    try {
      if (!await isRecording()) {
        throw const AudioException('No recording in progress');
      }

      await _recorder.pause();
      _stopDurationTimer();
      Logger.info('Recording paused');
    } catch (e) {
      Logger.error('Failed to pause recording', error: e);
      if (e is AppException) rethrow;
      throw AudioException('Failed to pause recording: ${e.toString()}');
    }
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    try {
      if (!await isRecording()) {
        throw const AudioException('No recording in progress');
      }

      await _recorder.resume();
      _startDurationTimer();
      Logger.info('Recording resumed');
    } catch (e) {
      Logger.error('Failed to resume recording', error: e);
      if (e is AppException) rethrow;
      throw AudioException('Failed to resume recording: ${e.toString()}');
    }
  }

  /// Cancel current recording
  Future<void> cancelRecording() async {
    try {
      if (await isRecording()) {
        await _recorder.stop();
      }
      _stopDurationTimer();
      
      if (_currentRecordingPath != null) {
        // Delete the recording file
        final fileName = _currentRecordingPath!.split('/').last;
        await FileStorage.deleteAudioFile(fileName);
      }
      
      _currentRecordingPath = null;
      _currentDuration = Duration.zero;
      Logger.info('Recording cancelled');
    } catch (e) {
      Logger.error('Failed to cancel recording', error: e);
      _currentRecordingPath = null;
    }
  }

  /// Get current recording path
  String? get currentRecordingPath => _currentRecordingPath;

  /// Start duration timer
  void _startDurationTimer() {
    _stopDurationTimer();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentDuration = _currentDuration + const Duration(seconds: 1);
      _durationController.add(_currentDuration);
    });
  }

  /// Stop duration timer
  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  /// Dispose resources
  void dispose() {
    _stopDurationTimer();
    _durationController.close();
    _recorder.dispose();
  }
}

