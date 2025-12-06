import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/services/audio_recorder_service.dart';
import '../../core/utils/result.dart';
import '../../domain/usecases/recordings/start_recording.dart';
import '../../domain/usecases/recordings/stop_recording.dart';
import '../../domain/usecases/recordings/pause_recording.dart';
import '../../domain/usecases/recordings/resume_recording.dart';
import '../../domain/usecases/recordings/check_recording_permission.dart';
import '../../domain/usecases/recordings/request_recording_permission.dart';
import '../../domain/usecases/recordings/create_recording.dart';
import '../pages/transcription_page.dart';
import '../providers/recording_provider.dart';

/// Recording page for capturing audio
class RecordingPage extends StatefulWidget {
  final String? appointmentId;

  const RecordingPage({
    super.key,
    this.appointmentId,
  });

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  StreamSubscription<Duration>? _durationSubscription;
  bool _hasInitialized = false;

  @override
  void dispose() {
    _durationSubscription?.cancel();
    super.dispose();
  }

  void _setupDurationListener(RecordingProvider provider) {
    final recorderService = di.sl<AudioRecorderService>();
    _durationSubscription?.cancel();
    _durationSubscription = recorderService.durationStream.listen((duration) {
      if (mounted) {
        provider.updateDuration(duration);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecordingProvider(
        startRecording: di.sl<StartRecording>(),
        stopRecording: di.sl<StopRecording>(),
        pauseRecording: di.sl<PauseRecording>(),
        resumeRecording: di.sl<ResumeRecording>(),
        checkPermission: di.sl<CheckRecordingPermission>(),
        requestPermission: di.sl<RequestRecordingPermission>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Record Consultation',
            style: TextStyle(fontSize: AppConstants.defaultFontSize),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Consumer<RecordingProvider>(
            builder: (context, provider, child) {
              // Initialize on first build
              if (!_hasInitialized) {
                _hasInitialized = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  provider.checkPermission();
                  _setupDurationListener(provider);
                });
              }

              if (provider.isCheckingPermission) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!provider.hasPermission) {
                return _buildPermissionRequest(context, provider);
              }

              return _buildRecordingInterface(context, provider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionRequest(BuildContext context, RecordingProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Microphone Permission Required',
            style: TextStyle(
              fontSize: AppConstants.defaultFontSize + 4,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Please grant microphone permission to record your consultation.',
            style: TextStyle(fontSize: AppConstants.defaultFontSize),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: AppConstants.minTouchTargetSize,
            child: ElevatedButton(
              onPressed: () => provider.requestPermission(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Grant Permission',
                style: const TextStyle(fontSize: AppConstants.defaultFontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingInterface(BuildContext context, RecordingProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Recording status indicator
          if (provider.isRecording)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fiber_manual_record,
                size: 60,
                color: Colors.red,
              ),
            )
          else
            Icon(
              Icons.mic,
              size: 80,
              color: Colors.grey[400],
            ),
          
          const SizedBox(height: 32),
          
          // Timer display
          Text(
            _formatDuration(provider.duration),
            style: TextStyle(
              fontSize: AppConstants.defaultFontSize + 20,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Error message
          if (provider.error != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.error!,
                      style: TextStyle(
                        fontSize: AppConstants.defaultFontSize,
                        color: Colors.red[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pause/Resume button
              if (provider.isRecording)
                _buildControlButton(
                  context,
                  icon: provider.isPaused ? Icons.play_arrow : Icons.pause,
                  label: provider.isPaused ? 'Resume' : 'Pause',
                  onPressed: provider.isPaused
                      ? () => provider.resumeRecording()
                      : () => provider.pauseRecording(),
                  color: Colors.orange,
                ),
              
              const SizedBox(width: 24),
              
              // Record/Stop button
              _buildControlButton(
                context,
                icon: provider.isRecording ? Icons.stop : Icons.fiber_manual_record,
                label: provider.isRecording ? 'Stop' : 'Start',
                onPressed: provider.isRecording
                    ? () => _handleStopRecording(context, provider)
                    : () => provider.startRecording(),
                color: provider.isRecording ? Colors.red : Colors.green,
                isLarge: true,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Instructions
          Text(
            provider.isRecording
                ? 'Recording in progress...'
                : 'Tap the button to start recording',
            style: TextStyle(
              fontSize: AppConstants.defaultFontSize,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isLarge = false,
  }) {
    final size = isLarge ? 80.0 : 60.0;
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: Icon(icon, size: isLarge ? 40 : 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: AppConstants.defaultFontSize - 2),
        ),
      ],
    );
  }

  Future<void> _handleStopRecording(BuildContext context, RecordingProvider provider) async {
    final result = await provider.stopRecording();
    
    if (mounted) {
      result.fold(
        onSuccess: (filePath) async {
          if (filePath != null) {
            // Get recording duration
            final recorderService = di.sl<AudioRecorderService>();
            final duration = recorderService.currentDuration;
            
            // Create recording entry
            final createRecording = di.sl<CreateRecording>();
            final fileName = filePath.split('/').last;
            
            final createResult = await createRecording(
              CreateRecordingParams(
                appointmentId: widget.appointmentId ?? '',
                audioFilePath: fileName,
                duration: duration,
              ),
            );
            
            createResult.fold(
              onSuccess: (recording) {
                // Navigate to transcription page
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => TranscriptionPage(
                      audioFilePath: filePath,
                      appointmentId: widget.appointmentId,
                      recordingId: recording.id,
                    ),
                  ),
                );
              },
              onError: (failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to save recording: ${failure.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            );
          }
        },
        onError: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

