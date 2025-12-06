import 'package:flutter/material.dart';
import '../../core/utils/result.dart';
import '../../core/utils/logger.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/usecase.dart';
import '../../domain/entities/tts_settings.dart';
import '../../domain/usecases/transcription/transcribe_audio.dart';
import '../../domain/usecases/summarization/summarize_text.dart';
import '../../domain/usecases/recordings/save_transcription_and_summary.dart';
import '../../domain/usecases/tts/speak_text.dart';
import '../../domain/usecases/tts/stop_speaking.dart';
import '../../domain/usecases/tts/pause_speaking.dart';
import '../../domain/usecases/tts/load_tts_settings.dart';
import '../../domain/usecases/tts/save_tts_settings.dart';

/// Provider for managing transcription and summarization state
class TranscriptionProvider extends ChangeNotifier {
  final TranscribeAudio _transcribeAudio;
  final SummarizeText _summarizeText;
  final SaveTranscriptionAndSummary _saveTranscriptionAndSummary;
  final SpeakText _speakText;
  final StopSpeaking _stopSpeaking;
  final PauseSpeaking _pauseSpeaking;
  final LoadTtsSettings _loadTtsSettings;
  final SaveTtsSettings _saveTtsSettings;
  final String? _recordingId;

  bool _isTranscribing = false;
  bool _isSummarizing = false;
  String? _transcription;
  String? _summary;
  String? _transcriptionError;
  String? _summaryError;
  double? _transcriptionProgress;
  bool _isSpeaking = false;
  String? _ttsError;
  String _ttsLanguage = 'en-US';
  double _ttsRate = 0.9;
  double _ttsPitch = 1.0;

  TranscriptionProvider({
    required TranscribeAudio transcribeAudio,
    required SummarizeText summarizeText,
    required SaveTranscriptionAndSummary saveTranscriptionAndSummary,
    required SpeakText speakText,
    required StopSpeaking stopSpeaking,
    required PauseSpeaking pauseSpeaking,
    required LoadTtsSettings loadTtsSettings,
    required SaveTtsSettings saveTtsSettings,
    String? recordingId,
  })  : _transcribeAudio = transcribeAudio,
        _summarizeText = summarizeText,
        _saveTranscriptionAndSummary = saveTranscriptionAndSummary,
        _speakText = speakText,
        _stopSpeaking = stopSpeaking,
        _pauseSpeaking = pauseSpeaking,
        _loadTtsSettings = loadTtsSettings,
        _saveTtsSettings = saveTtsSettings,
        _recordingId = recordingId;

  bool get isTranscribing => _isTranscribing;
  bool get isSummarizing => _isSummarizing;
  String? get transcription => _transcription;
  String? get summary => _summary;
  String? get transcriptionError => _transcriptionError;
  String? get summaryError => _summaryError;
  double? get transcriptionProgress => _transcriptionProgress;
  bool get isSpeaking => _isSpeaking;
  String? get ttsError => _ttsError;
  String get ttsLanguage => _ttsLanguage;
  double get ttsRate => _ttsRate;
  double get ttsPitch => _ttsPitch;

  /// Transcribe audio file
  Future<void> transcribeAudio(String audioFilePath) async {
    Logger.info('TranscriptionProvider: Starting transcription for: $audioFilePath');
    _isTranscribing = true;
    _transcriptionError = null;
    _transcription = null;
    _transcriptionProgress = 0.0;
    notifyListeners();

    try {
      Logger.info('TranscriptionProvider: Calling TranscribeAudio use case...');
      final result = await _transcribeAudio(
        TranscribeAudioParams(audioFilePath),
      );

      result.fold(
        onSuccess: (transcription) {
          Logger.info('TranscriptionProvider: Transcription successful (${transcription.length} chars)');
          _transcription = transcription;
          _isTranscribing = false;
          _transcriptionProgress = 1.0;
          notifyListeners();
          
          // Automatically start summarization
          Logger.info('TranscriptionProvider: Starting automatic summarization...');
          summarizeTranscription();
        },
        onError: (failure) {
          Logger.error('TranscriptionProvider: Transcription failed', error: failure);
          Logger.error('TranscriptionProvider: Failure type: ${failure.runtimeType}');
          Logger.error('TranscriptionProvider: Failure message: ${failure.message}');
          _transcriptionError = failure.message.isNotEmpty 
              ? failure.message 
              : 'An error occurred during transcription. Please check logs for details.';
          _isTranscribing = false;
          _transcriptionProgress = null;
          notifyListeners();
        },
      );
    } catch (e, stackTrace) {
      Logger.error('TranscriptionProvider: Unexpected error during transcription', error: e, stackTrace: stackTrace);
      _transcriptionError = 'Unexpected error: ${e.toString()}';
      _isTranscribing = false;
      _transcriptionProgress = null;
      notifyListeners();
    }
  }

  /// Summarize transcription
  Future<void> summarizeTranscription() async {
    if (_transcription == null || _transcription!.isEmpty) {
      return;
    }

    _isSummarizing = true;
    _summaryError = null;
    _summary = null;
    notifyListeners();

    final result = await _summarizeText(
      SummarizeTextParams(text: _transcription!),
    );

    result.fold(
      onSuccess: (summary) {
        _summary = summary;
        _isSummarizing = false;
        notifyListeners();
      },
      onError: (failure) {
        _summaryError = failure.message;
        _isSummarizing = false;
        notifyListeners();
      },
    );
  }

  /// Update transcription progress (for future use with progress callbacks)
  void updateProgress(double progress) {
    _transcriptionProgress = progress;
    notifyListeners();
  }

  /// Save transcription and summary to recording
  Future<Result<void>> saveToRecording() async {
    final recordingId = _recordingId;
    final transcription = _transcription;
    final summary = _summary;
    
    if (recordingId == null || transcription == null || summary == null) {
      return const Error(ValidationFailure('Missing required data to save'));
    }

    final result = await _saveTranscriptionAndSummary(
      SaveTranscriptionAndSummaryParams(
        recordingId: recordingId,
        transcription: transcription,
        summary: summary,
      ),
    );

    return result.fold(
      onSuccess: (_) => const Success(null),
      onError: (failure) => Error(failure),
    );
  }

  /// Reset state
  void reset() {
    _isTranscribing = false;
    _isSummarizing = false;
    _transcription = null;
    _summary = null;
    _transcriptionError = null;
    _summaryError = null;
    _transcriptionProgress = null;
    _isSpeaking = false;
    _ttsError = null;
    notifyListeners();
  }

  /// Load TTS settings from storage
  Future<void> loadTtsSettings() async {
    final result = await _loadTtsSettings(NoParams());
    result.fold(
      onSuccess: (settings) {
        _ttsLanguage = settings.language;
        _ttsRate = settings.rate;
        _ttsPitch = settings.pitch;
        notifyListeners();
      },
      onError: (_) {},
    );
  }

  /// Speak the summary via TTS
  Future<void> speakSummary() async {
    if (_summary == null || _summary!.isEmpty) return;
    _isSpeaking = true;
    _ttsError = null;
    notifyListeners();

    final result = await _speakText(
      SpeakTextParams(
        text: _summary!,
        language: _ttsLanguage,
        rate: _ttsRate,
        pitch: _ttsPitch,
      ),
    );

    result.fold(
      onSuccess: (_) {
        _isSpeaking = false;
        notifyListeners();
      },
      onError: (failure) {
        _isSpeaking = false;
        _ttsError = failure.message;
        notifyListeners();
      },
    );
  }

  /// Stop TTS
  Future<void> stopSpeaking() async {
    final result = await _stopSpeaking(NoParams());
    result.fold(
      onSuccess: (_) {
        _isSpeaking = false;
        notifyListeners();
      },
      onError: (failure) {
        _ttsError = failure.message;
        _isSpeaking = false;
        notifyListeners();
      },
    );
  }

  /// Pause TTS
  Future<void> pauseSpeaking() async {
    final result = await _pauseSpeaking(NoParams());
    result.fold(
      onSuccess: (_) {
        _isSpeaking = false;
        notifyListeners();
      },
      onError: (failure) {
        _ttsError = failure.message;
        _isSpeaking = false;
        notifyListeners();
      },
    );
  }

  /// Set language
  void setTtsLanguage(String language) {
    _ttsLanguage = language;
    _persistTtsSettings();
    notifyListeners();
  }

  /// Set rate (0.5 - 1.5)
  void setTtsRate(double rate) {
    _ttsRate = rate.clamp(0.5, 1.5);
    _persistTtsSettings();
    notifyListeners();
  }

  /// Set pitch (0.5 - 2.0)
  void setTtsPitch(double pitch) {
    _ttsPitch = pitch.clamp(0.5, 2.0);
    _persistTtsSettings();
    notifyListeners();
  }

  Future<void> _persistTtsSettings() async {
    final settings = TtsSettings(
      language: _ttsLanguage,
      rate: _ttsRate,
      pitch: _ttsPitch,
    );
    await _saveTtsSettings(SaveTtsSettingsParams(settings));
  }
}

