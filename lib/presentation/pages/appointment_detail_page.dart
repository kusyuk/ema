import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/utils/result.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/recording.dart';
import '../../domain/usecases/appointments/get_appointment_by_id.dart';
import '../../domain/usecases/recordings/get_recordings_by_appointment.dart';
import 'recording_page.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final getAppt = di.sl<GetAppointmentById>();
    final getRecs = di.sl<GetRecordingsByAppointment>();

    final apptResult = await getAppt(GetAppointmentByIdParams(widget.appointmentId));
    final recResult = await getRecs(GetRecordingsByAppointmentParams(widget.appointmentId));

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
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: _appointment == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecordingPage(appointmentId: _appointment!.id),
                  ),
                );
              },
              icon: const Icon(Icons.mic),
              label: const Text('New Recording'),
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
              style: TextStyle(
                fontSize: AppConstants.defaultFontSize + 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(appt.hospitalName, style: const TextStyle(fontSize: AppConstants.defaultFontSize)),
            const SizedBox(height: 8),
            Text(_formatDateTime(appt.dateTime), style: const TextStyle(color: Colors.grey)),
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
              const Text('Recordings', style: TextStyle(fontWeight: FontWeight.bold)),
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
              child: Text('Recordings', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ..._recordings.map(_buildRecordingTile).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingTile(Recording rec) {
    return ListTile(
      leading: const Icon(Icons.mic),
      title: Text('Recording ${rec.id}'),
      subtitle: Text(
        '${_formatDateTime(rec.createdAt)} • ${_formatDuration(rec.duration)}',
        style: const TextStyle(fontSize: AppConstants.defaultFontSize - 2),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // For now, just show a simple dialog with transcription/summary if present
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Recording'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('File: ${rec.audioFilePath}'),
                  const SizedBox(height: 8),
                  Text('Duration: ${_formatDuration(rec.duration)}'),
                  const SizedBox(height: 12),
                  if ((rec.summarizedTranscription ?? '').isNotEmpty) ...[
                    const Text('Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(rec.summarizedTranscription!),
                  ] else if ((rec.rawTranscription ?? '').isNotEmpty) ...[
                    const Text('Transcription:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(rec.rawTranscription!),
                  ] else
                    const Text('No transcription available'),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

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


