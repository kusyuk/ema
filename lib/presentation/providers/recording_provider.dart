import 'package:flutter/material.dart';
import '../../core/utils/result.dart';
import '../../domain/usecases/recordings/start_recording.dart';
import '../../domain/usecases/recordings/stop_recording.dart';
import '../../domain/usecases/recordings/pause_recording.dart';
import '../../domain/usecases/recordings/resume_recording.dart';
import '../../domain/usecases/recordings/check_recording_permission.dart';
import '../../domain/usecases/recordings/request_recording_permission.dart';

/// Provider for managing recording state
class RecordingProvider extends ChangeNotifier {
  final StartRecording _startRecording;
  final StopRecording _stopRecording;
  final PauseRecording _pauseRecording;
  final ResumeRecording _resumeRecording;
  final CheckRecordingPermission _checkPermission;
  final RequestRecordingPermission _requestPermission;

  bool _isRecording = false;
  bool _isPaused = false;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  Duration _duration = Duration.zero;
  String? _error;

  RecordingProvider({
    required StartRecording startRecording,
    required StopRecording stopRecording,
    required PauseRecording pauseRecording,
    required ResumeRecording resumeRecording,
    required CheckRecordingPermission checkPermission,
    required RequestRecordingPermission requestPermission,
  })  : _startRecording = startRecording,
        _stopRecording = stopRecording,
        _pauseRecording = pauseRecording,
        _resumeRecording = resumeRecording,
        _checkPermission = checkPermission,
        _requestPermission = requestPermission;

  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  bool get hasPermission => _hasPermission;
  bool get isCheckingPermission => _isCheckingPermission;
  Duration get duration => _duration;
  String? get error => _error;

  /// Check recording permission
  Future<void> checkPermission() async {
    _isCheckingPermission = true;
    _error = null;
    notifyListeners();

    final result = await _checkPermission();
    result.fold(
      onSuccess: (hasPermission) {
        _hasPermission = hasPermission;
        _isCheckingPermission = false;
        notifyListeners();
      },
      onError: (failure) {
        _error = failure.message;
        _hasPermission = false;
        _isCheckingPermission = false;
        notifyListeners();
      },
    );
  }

  /// Request permission
  Future<void> requestPermission() async {
    _isCheckingPermission = true;
    _error = null;
    notifyListeners();

    final result = await _requestPermission();
    result.fold(
      onSuccess: (hasPermission) {
        _hasPermission = hasPermission;
        _isCheckingPermission = false;
        notifyListeners();
      },
      onError: (failure) {
        _error = failure.message;
        _hasPermission = false;
        _isCheckingPermission = false;
        notifyListeners();
      },
    );
  }

  /// Start recording
  Future<void> startRecording() async {
    _error = null;
    notifyListeners();

    final result = await _startRecording();
    result.fold(
      onSuccess: (filePath) {
        _isRecording = true;
        _isPaused = false;
        _duration = Duration.zero;
        notifyListeners();
      },
      onError: (failure) {
        _error = failure.message;
        notifyListeners();
      },
    );
  }

  /// Stop recording
  Future<Result<String?>> stopRecording() async {
    _error = null;
    notifyListeners();

    final result = await _stopRecording();
    result.fold(
      onSuccess: (filePath) {
        _isRecording = false;
        _isPaused = false;
        _duration = Duration.zero;
        notifyListeners();
      },
      onError: (failure) {
        _error = failure.message;
        notifyListeners();
      },
    );

    return result;
  }

  /// Pause recording
  Future<void> pauseRecording() async {
    _error = null;
    notifyListeners();

    final result = await _pauseRecording();
    result.fold(
      onSuccess: (_) {
        _isPaused = true;
        notifyListeners();
      },
      onError: (failure) {
        _error = failure.message;
        notifyListeners();
      },
    );
  }

  /// Resume recording
  Future<void> resumeRecording() async {
    _error = null;
    notifyListeners();

    final result = await _resumeRecording();
    result.fold(
      onSuccess: (_) {
        _isPaused = false;
        notifyListeners();
      },
      onError: (failure) {
        _error = failure.message;
        notifyListeners();
      },
    );
  }

  /// Update duration
  void updateDuration(Duration duration) {
    _duration = duration;
    notifyListeners();
  }
}

