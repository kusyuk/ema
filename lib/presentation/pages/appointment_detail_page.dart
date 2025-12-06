import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/services/audio_player_service.dart';
import '../../core/services/tts_service.dart';
import '../../core/utils/file_storage.dart';
import '../../core/utils/result.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/notification_service.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/recording.dart';
import '../../domain/usecases/appointments/get_appointment_by_id.dart';
import '../../domain/usecases/appointments/delete_appointment.dart';
import '../../domain/usecases/recordings/get_recordings_by_appointment.dart';
import '../../domain/usecases/recordings/delete_recording.dart';
import 'appointment_form_page.dart';

class AppointmentDetailPage extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailPage({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  Appointment? _appointment;
  List<Recording> _recordings = [];
  bool _loading = true;
  String? _error;
  final AudioPlayerService _player = di.sl<AudioPlayerService>();
  final TtsService _tts = di.sl<TtsService>();
  bool _isSpeaking = false;
  String? _ttsError;

  void _shareAppointment() {
    if (_appointment == null) return;
    final appt = _appointment!;

    Recording? preferred;
    for (final rec in _recordings) {
      if ((rec.summarizedTranscription ?? '').isNotEmpty) {
        preferred = rec;
        break;
      }
    }
    preferred ??= _recordings.isNotEmpty ? _recordings.first : null;

    final buffer = StringBuffer();
    buffer.writeln('Appointment');
    buffer.writeln('Doctor: ${appt.doctorName}');
    buffer.writeln('Hospital: ${appt.hospitalName}');
    buffer.writeln('When: ${_formatDateTime(appt.dateTime)}');
    if ((appt.speciality ?? '').isNotEmpty) {
      buffer.writeln('Speciality: ${appt.speciality}');
    }
    if ((appt.remarks ?? '').isNotEmpty) {
      buffer.writeln('Notes: ${appt.remarks}');
    }
    if (preferred != null) {
      buffer.writeln('');
      if ((preferred.summarizedTranscription ?? '').isNotEmpty) {
        buffer.writeln('Summary:');
        buffer.writeln(preferred.summarizedTranscription);
      } else if ((preferred.rawTranscription ?? '').isNotEmpty) {
        buffer.writeln('Transcription:');
        buffer.writeln(preferred.rawTranscription);
      }
    }

    Share.share(buffer.toString(), subject: 'Appointment ${appt.doctorName}');
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _player.stop();
    _tts.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final getAppt = di.sl<GetAppointmentById>();
    final getRecs = di.sl<GetRecordingsByAppointment>();

    final apptResult = await getAppt(
      GetAppointmentByIdParams(widget.appointmentId),
    );
    final recResult = await getRecs(
      GetRecordingsByAppointmentParams(widget.appointmentId),
    );

    apptResult.fold(
      onSuccess: (appt) {
        _appointment = appt;
      },
      onError: (failure) {
        _error = failure.message;
      },
    );

    recResult.fold(
      onSuccess: (recs) {
        _recordings = recs;
      },
      onError: (failure) {
        _error ??= failure.message;
      },
    );

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointment Details',
          style: TextStyle(fontSize: AppConstants.defaultFontSize),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _appointment == null
                ? null
                : () async {
                    final updated = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => AppointmentFormPage(existing: _appointment),
                      ),
                    );
                    if (updated == true && mounted) {
                      _load();
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: _appointment == null
                ? null
                : () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete appointment?'),
                        content: const Text('This will remove the appointment. Recordings remain stored.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      if (!mounted) return;
                      final delete = di.sl<DeleteAppointment>();
                      final deleteRecording = di.sl<DeleteRecording>();
                      final notificationService = di.sl<NotificationService>();
                      await notificationService.cancelAppointmentReminder(_appointment!.id);
                      final result = await delete(DeleteAppointmentParams(_appointment!.id));
                      if (!mounted) return;
                      result.fold(
                        onSuccess: (_) async {
                          // Cascade delete recordings and audio files for this appointment
                          for (final rec in _recordings) {
                            await deleteRecording(DeleteRecordingParams(rec.id));
                            try {
                              await FileStorage.deleteAudioFile(rec.audioFilePath);
                            } catch (_) {}
                          }
                          navigator.pop(true);
                        },
                        onError: (failure) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Delete failed: ${failure.message}')),
                          );
                        },
                      );
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: _appointment == null ? null : _shareAppointment,
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_appointment == null) {
      return const Center(child: Text('Appointment not found'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildRecordingsCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final appt = _appointment!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appt.doctorName,
              style: const TextStyle(
                fontSize: AppConstants.defaultFontSize + 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              appt.hospitalName,
              style: const TextStyle(fontSize: AppConstants.defaultFontSize),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDateTime(appt.dateTime),
              style: const TextStyle(color: Colors.grey),
            ),
            if ((appt.speciality ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Speciality: ${appt.speciality}'),
            ],
            if ((appt.remarks ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${appt.remarks}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingsCard() {
    if (_recordings.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recordings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'No recordings yet for this appointment',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Recordings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ..._recordings.map(_buildRecordingTile),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingTile(Recording rec) {
    final hasSummary = (rec.summarizedTranscription ?? '').isNotEmpty;
    final hasTranscript = (rec.rawTranscription ?? '').isNotEmpty;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mic),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recording ${rec.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.defaultFontSize,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${_formatDateTime(rec.createdAt)} • ${_formatDuration(rec.duration)}',
              style: const TextStyle(
                fontSize: AppConstants.defaultFontSize - 2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Playback',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final file = FileStorage.getAudioFile(rec.audioFilePath);
                      await _player.loadAudio(file.path);
                      await _player.play();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Play failed: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Stop',
                  onPressed: () async {
                    await _player.stop();
                  },
                  icon: const Icon(Icons.stop),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'TTS Summary',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: hasSummary
                      ? () async {
                          try {
                            setState(() {
                              _isSpeaking = true;
                              _ttsError = null;
                            });
                            await _tts.speak(
                              text: rec.summarizedTranscription!,
                              rate: 0.7,
                              pitch: 1.0,
                            );
                            setState(() {
                              _isSpeaking = false;
                            });
                          } catch (e) {
                            setState(() {
                              _ttsError = 'TTS failed';
                              _isSpeaking = false;
                            });
                          }
                        }
                      : null,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Play Summary'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Stop TTS',
                  onPressed: _isSpeaking
                      ? () async {
                          await _tts.stop();
                          setState(() {
                            _isSpeaking = false;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.stop),
                ),
              ],
            ),
            if (_ttsError != null) ...[
              const SizedBox(height: 6),
              Text(_ttsError!, style: TextStyle(color: Colors.red[700])),
            ],
            const SizedBox(height: 12),
            if (hasSummary) ...[
              const Text(
                'Summary:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(rec.summarizedTranscription!),
            ] else if (hasTranscript) ...[
              const Text(
                'Transcription:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(rec.rawTranscription!),
            ] else
              const Text('No transcription available'),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    if (appointmentDate == today) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (appointmentDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow at ${_formatTime(dateTime)}';
    } else if (appointmentDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
