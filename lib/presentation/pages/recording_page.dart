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
import '../../domain/usecases/appointments/create_appointment.dart';
import '../../domain/usecases/appointments/get_appointment_by_id.dart';
import '../../domain/usecases/appointments/update_appointment.dart';
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
          const Text(
            'Microphone Permission Required',
            style: TextStyle(
              fontSize: AppConstants.defaultFontSize + 4,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
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
              child: const Text(
                'Grant Permission',
                style: TextStyle(fontSize: AppConstants.defaultFontSize),
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
            style: const TextStyle(
              fontSize: AppConstants.defaultFontSize + 20,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          
          // Duration warning when approaching limit
          if (provider.isRecording && provider.duration >= AppConstants.recordingWarningThreshold)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recording limit approaching (${AppConstants.maxRecordingDuration.inMinutes} min max)',
                    style: TextStyle(
                      fontSize: AppConstants.defaultFontSize - 2,
                      color: Colors.orange[900],
                    ),
                  ),
                ],
              ),
            ),
          
          // Estimated credit cost (rough estimate: ~1 credit per 15-20 seconds)
          if (provider.isRecording && provider.duration.inSeconds > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Est. credits: ~${_estimateCredits(provider.duration)}',
                style: TextStyle(
                  fontSize: AppConstants.defaultFontSize - 4,
                  color: Colors.grey[600],
                ),
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
          style: const TextStyle(fontSize: AppConstants.defaultFontSize - 2),
        ),
      ],
    );
  }

  Future<void> _handleStopRecording(BuildContext context, RecordingProvider provider) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final result = await provider.stopRecording();
    
    if (mounted) {
      result.fold(
        onSuccess: (filePath) async {
          if (filePath != null) {
            // Get recording duration
            final recorderService = di.sl<AudioRecorderService>();
            final duration = recorderService.currentDuration;
            final fileName = filePath.split('/').last;

            // Ensure we have an appointment ID; create a placeholder if none
            String appointmentId = widget.appointmentId ?? '';
            if (appointmentId.isEmpty) {
              final createAppointment = di.sl<CreateAppointment>();
              final now = DateTime.now();
              final apptResult = await createAppointment(
                CreateAppointmentParams(
                  dateTime: now,
                  hospitalName: 'Unassigned',
                  doctorName: 'Unknown',
                  remarks: 'Auto-created for recording',
                  location: '',
                  speciality: '',
                ),
              );
              apptResult.fold(
                onSuccess: (appt) {
                  appointmentId = appt.id;
                },
                onError: (_) {},
              );
            }

            // Create recording entry
            final createRecording = di.sl<CreateRecording>();
            final createResult = await createRecording(
              CreateRecordingParams(
                appointmentId: appointmentId,
                audioFilePath: fileName,
                duration: duration,
              ),
            );
            
            createResult.fold(
              onSuccess: (recording) async {
                // Link recording to appointment if appointment exists
                if (appointmentId.isNotEmpty) {
                  final getAppt = di.sl<GetAppointmentById>();
                  final updateAppt = di.sl<UpdateAppointment>();
                  final apptResult = await getAppt(GetAppointmentByIdParams(appointmentId));
                  await apptResult.fold(
                    onSuccess: (appt) async {
                      final updated = appt.copyWith(
                        recordingIds: [...appt.recordingIds, recording.id],
                        updatedAt: DateTime.now(),
                      );
                      await updateAppt(UpdateAppointmentParams(updated));
                    },
                    onError: (_) async {},
                  );
                }

                // Navigate to transcription page
                if (!mounted) return;
                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => TranscriptionPage(
                      audioFilePath: fileName,
                      appointmentId: appointmentId.isEmpty ? null : appointmentId,
                      recordingId: recording.id,
                    ),
                  ),
                );
              },
              onError: (failure) {
                messenger.showSnackBar(
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
          messenger.showSnackBar(
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

  /// Estimate credit cost based on recording duration
  /// Rough estimate: ~1 credit per 15-20 seconds of audio with optimized settings
  int _estimateCredits(Duration duration) {
    // With optimized settings (16kHz, 64kbps), estimate ~1 credit per 15 seconds
    final estimatedCredits = (duration.inSeconds / 15).ceil();
    return estimatedCredits.clamp(1, 10); // Cap at 10 for display
  }
}

