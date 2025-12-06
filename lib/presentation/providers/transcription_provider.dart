import 'package:flutter/material.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../../domain/usecases/transcription/transcribe_audio.dart';
import '../../domain/usecases/summarization/summarize_text.dart';
import '../../domain/usecases/recordings/save_transcription_and_summary.dart';

/// Provider for managing transcription and summarization state
class TranscriptionProvider extends ChangeNotifier {
  final TranscribeAudio _transcribeAudio;
  final SummarizeText _summarizeText;
  final SaveTranscriptionAndSummary _saveTranscriptionAndSummary;
  final String? _recordingId;

  bool _isTranscribing = false;
  bool _isSummarizing = false;
  String? _transcription;
  String? _summary;
  String? _transcriptionError;
  String? _summaryError;
  double? _transcriptionProgress;

  TranscriptionProvider({
    required TranscribeAudio transcribeAudio,
    required SummarizeText summarizeText,
    required SaveTranscriptionAndSummary saveTranscriptionAndSummary,
    String? recordingId,
  })  : _transcribeAudio = transcribeAudio,
        _summarizeText = summarizeText,
        _saveTranscriptionAndSummary = saveTranscriptionAndSummary,
        _recordingId = recordingId;

  bool get isTranscribing => _isTranscribing;
  bool get isSummarizing => _isSummarizing;
  String? get transcription => _transcription;
  String? get summary => _summary;
  String? get transcriptionError => _transcriptionError;
  String? get summaryError => _summaryError;
  double? get transcriptionProgress => _transcriptionProgress;

  /// Transcribe audio file
  Future<void> transcribeAudio(String audioFilePath) async {
    _isTranscribing = true;
    _transcriptionError = null;
    _transcription = null;
    _transcriptionProgress = 0.0;
    notifyListeners();

    final result = await _transcribeAudio(
      TranscribeAudioParams(audioFilePath),
    );

    result.fold(
      onSuccess: (transcription) {
        _transcription = transcription;
        _isTranscribing = false;
        _transcriptionProgress = 1.0;
        notifyListeners();
        
        // Automatically start summarization
        summarizeTranscription();
      },
      onError: (failure) {
        _transcriptionError = failure.message;
        _isTranscribing = false;
        _transcriptionProgress = null;
        notifyListeners();
      },
    );
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
    notifyListeners();
  }
}

