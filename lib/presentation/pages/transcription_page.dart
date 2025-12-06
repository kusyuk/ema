import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/utils/result.dart';
import '../../domain/usecases/transcription/transcribe_audio.dart';
import '../../domain/usecases/summarization/summarize_text.dart';
import '../../domain/usecases/recordings/save_transcription_and_summary.dart';
import '../../domain/usecases/tts/speak_text.dart';
import '../../domain/usecases/tts/stop_speaking.dart';
import '../../domain/usecases/tts/pause_speaking.dart';
import '../../domain/usecases/tts/load_tts_settings.dart';
import '../../domain/usecases/tts/save_tts_settings.dart';
import '../providers/transcription_provider.dart';
import '../widgets/labeled_slider.dart';

/// Transcription page for processing audio and generating summaries
class TranscriptionPage extends StatefulWidget {
  final String audioFilePath;
  final String? appointmentId;
  final String? recordingId;

  const TranscriptionPage({
    super.key,
    required this.audioFilePath,
    this.appointmentId,
    this.recordingId,
  });

  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {
  bool _hasInitialized = false;

  void _startTranscription(TranscriptionProvider provider) {
    provider.transcribeAudio(widget.audioFilePath);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TranscriptionProvider(
        transcribeAudio: di.sl<TranscribeAudio>(),
        summarizeText: di.sl<SummarizeText>(),
        saveTranscriptionAndSummary: di.sl<SaveTranscriptionAndSummary>(),
        speakText: di.sl<SpeakText>(),
        stopSpeaking: di.sl<StopSpeaking>(),
        pauseSpeaking: di.sl<PauseSpeaking>(),
        loadTtsSettings: di.sl<LoadTtsSettings>(),
        saveTtsSettings: di.sl<SaveTtsSettings>(),
        recordingId: widget.recordingId,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Processing Audio',
            style: TextStyle(fontSize: AppConstants.defaultFontSize),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Consumer<TranscriptionProvider>(
            builder: (context, provider, child) {
              // Initialize on first build
              if (!_hasInitialized) {
                _hasInitialized = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  provider.loadTtsSettings();
                  _startTranscription(provider);
                });
              }
              
              return _buildContent(context, provider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TranscriptionProvider provider) {
    if (provider.isTranscribing) {
      return _buildTranscribingView(provider);
    }

    if (provider.transcriptionError != null) {
      return _buildErrorView(context, provider);
    }

    if (provider.transcription != null && provider.isSummarizing) {
      return _buildSummarizingView(provider);
    }

    if (provider.transcription != null && provider.summaryError != null) {
      return _buildSummaryErrorView(context, provider);
    }

    if (provider.transcription != null && provider.summary != null) {
      return _buildResultsView(context, provider);
    }

    return _buildInitialView();
  }

  Widget _buildInitialView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('Preparing to process audio...'),
        ],
      ),
    );
  }

  Widget _buildTranscribingView(TranscriptionProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 32),
          Text(
            'Transcribing Audio',
            style: TextStyle(
              fontSize: AppConstants.defaultFontSize + 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please wait while we convert your audio to text...',
            style: TextStyle(fontSize: AppConstants.defaultFontSize),
            textAlign: TextAlign.center,
          ),
          if (provider.transcriptionProgress != null) ...[
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: provider.transcriptionProgress,
            ),
            const SizedBox(height: 8),
            Text(
              '${(provider.transcriptionProgress! * 100).toInt()}%',
              style: TextStyle(fontSize: AppConstants.defaultFontSize - 2),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummarizingView(TranscriptionProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 32),
          Text(
            'Creating Summary',
            style: TextStyle(
              fontSize: AppConstants.defaultFontSize + 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Summarizing in simple, easy-to-understand language...',
            style: TextStyle(fontSize: AppConstants.defaultFontSize),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, TranscriptionProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            'Transcription Failed',
            style: TextStyle(
              fontSize: AppConstants.defaultFontSize + 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            provider.transcriptionError ?? 'An error occurred',
            style: TextStyle(fontSize: AppConstants.defaultFontSize),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: AppConstants.minTouchTargetSize,
            child: ElevatedButton(
              onPressed: () => provider.transcribeAudio(widget.audioFilePath),
              child: Text(
                'Retry',
                style: TextStyle(fontSize: AppConstants.defaultFontSize),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: AppConstants.minTouchTargetSize,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: AppConstants.defaultFontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryErrorView(
    BuildContext context,
    TranscriptionProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber,
            size: 80,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            'Summary Failed',
            style: TextStyle(
              fontSize: AppConstants.defaultFontSize + 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            provider.summaryError ?? 'An error occurred',
            style: TextStyle(fontSize: AppConstants.defaultFontSize),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: AppConstants.minTouchTargetSize,
            child: ElevatedButton(
              onPressed: () => provider.summarizeTranscription(),
              child: Text(
                'Retry Summary',
                style: TextStyle(fontSize: AppConstants.defaultFontSize),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: AppConstants.minTouchTargetSize,
            child: OutlinedButton(
              onPressed: () => _showTranscriptionOnly(context, provider),
              child: Text(
                'View Transcription Only',
                style: TextStyle(fontSize: AppConstants.defaultFontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(
    BuildContext context,
    TranscriptionProvider provider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Section
          Text(
            'Summary',
            style: TextStyle(
              fontSize: AppConstants.defaultFontSize + 6,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              provider.summary!,
              style: TextStyle(
                fontSize: AppConstants.defaultFontSize,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // TTS Controls
          Text(
            'Listen to Summary',
            style: TextStyle(
              fontSize: AppConstants.defaultFontSize + 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.summary == null
                      ? null
                      : () => provider.speakSummary(),
                  icon: const Icon(Icons.volume_up),
                  label: const Text(
                    'Play Summary',
                    style: TextStyle(fontSize: AppConstants.defaultFontSize),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Pause',
                onPressed: provider.isSpeaking ? () => provider.pauseSpeaking() : null,
                icon: const Icon(Icons.pause),
              ),
              IconButton(
                tooltip: 'Stop',
                onPressed: provider.isSpeaking ? () => provider.stopSpeaking() : null,
                icon: const Icon(Icons.stop),
              ),
            ],
          ),

          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: provider.ttsLanguage,
            decoration: const InputDecoration(
              labelText: 'Language',
            ),
            items: const [
              DropdownMenuItem(value: 'en-US', child: Text('English (US)')),
              DropdownMenuItem(value: 'en-GB', child: Text('English (UK)')),
              DropdownMenuItem(value: 'es-ES', child: Text('Spanish')),
              DropdownMenuItem(value: 'fr-FR', child: Text('French')),
            ],
            onChanged: (value) {
              if (value != null) provider.setTtsLanguage(value);
            },
          ),

          const SizedBox(height: 12),
          LabeledSlider(
            label: 'Speech Rate',
            value: provider.ttsRate,
            min: 0.5,
            max: 1.5,
            onChanged: (v) => provider.setTtsRate(v),
          ),

          const SizedBox(height: 12),
          LabeledSlider(
            label: 'Pitch',
            value: provider.ttsPitch,
            min: 0.5,
            max: 2.0,
            onChanged: (v) => provider.setTtsPitch(v),
          ),

          if (provider.ttsError != null) ...[
            const SizedBox(height: 8),
            Text(
              provider.ttsError!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: AppConstants.defaultFontSize - 2,
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Regenerate Summary Button
          SizedBox(
            width: double.infinity,
            height: AppConstants.minTouchTargetSize,
            child: OutlinedButton.icon(
              onPressed: () => provider.summarizeTranscription(),
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Regenerate Summary',
                style: TextStyle(fontSize: AppConstants.defaultFontSize),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Transcription Section (Expandable)
          ExpansionTile(
            title: const Text(
              'Full Transcription',
              style: TextStyle(fontSize: AppConstants.defaultFontSize),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  provider.transcription!,
                  style: const TextStyle(
                    fontSize: AppConstants.defaultFontSize,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: AppConstants.minTouchTargetSize,
            child: ElevatedButton(
              onPressed: () => _handleSave(context, provider),
              child: const Text(
                'Save & Continue',
                style: TextStyle(fontSize: AppConstants.defaultFontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTranscriptionOnly(
    BuildContext context,
    TranscriptionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transcription'),
        content: SingleChildScrollView(
          child: Text(
            provider.transcription!,
            style: const TextStyle(fontSize: AppConstants.defaultFontSize),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, TranscriptionProvider provider) async {
    final result = await provider.saveToRecording();
    
    if (!mounted) return;
    
    result.fold(
      onSuccess: (_) {
        if (mounted) {
          Navigator.of(context).pop({
            'transcription': provider.transcription,
            'summary': provider.summary,
            'saved': true,
          });
        }
      },
      onError: (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}

