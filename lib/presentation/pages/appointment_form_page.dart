import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/utils/result.dart';
import '../../core/services/notification_service.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/appointments/create_appointment.dart';
import '../../domain/usecases/appointments/update_appointment.dart';

class AppointmentFormPage extends StatefulWidget {
  final Appointment? existing;

  const AppointmentFormPage({super.key, this.existing});

  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDateTime;
  late final TextEditingController _hospitalCtrl;
  late final TextEditingController _doctorCtrl;
  late final TextEditingController _specialityCtrl;
  late final TextEditingController _remarksCtrl;
  late final TextEditingController _locationCtrl;
  bool _submitting = false;
  bool _reminderEnabled = true;
  int _reminderMinutes = AppConstants.defaultReminderMinutes;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final appt = widget.existing;
    _selectedDateTime = appt?.dateTime ?? DateTime.now();
    _hospitalCtrl = TextEditingController(text: appt?.hospitalName ?? '');
    _doctorCtrl = TextEditingController(text: appt?.doctorName ?? '');
    _specialityCtrl = TextEditingController(text: appt?.speciality ?? '');
    _remarksCtrl = TextEditingController(text: appt?.remarks ?? '');
    _locationCtrl = TextEditingController(text: appt?.location ?? '');
    _reminderEnabled = appt?.reminderEnabled ?? true;
    _reminderMinutes = appt?.reminderMinutes ?? AppConstants.defaultReminderMinutes;
  }

  @override
  void dispose() {
    _hospitalCtrl.dispose();
    _doctorCtrl.dispose();
    _specialityCtrl.dispose();
    _remarksCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    if (!mounted) return;
    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    setState(() {
      _submitting = true;
    });

    final hospitalName = _hospitalCtrl.text.trim();
    final doctorName = _doctorCtrl.text.trim();
    final speciality = _specialityCtrl.text.trim().isEmpty ? null : _specialityCtrl.text.trim();
    final remarks = _remarksCtrl.text.trim().isEmpty ? null : _remarksCtrl.text.trim();
    final location = _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim();

    if (_isEdit) {
      final update = di.sl<UpdateAppointment>();
      final updated = widget.existing!.copyWith(
        dateTime: _selectedDateTime,
        hospitalName: hospitalName,
        doctorName: doctorName,
        speciality: speciality,
        remarks: remarks,
        location: location,
        reminderEnabled: _reminderEnabled,
        reminderMinutes: _reminderMinutes,
      );
      final result = await update(UpdateAppointmentParams(updated));
      if (!mounted) return;
      result.fold(
        onSuccess: (_) async {
          final notificationService = di.sl<NotificationService>();
          await notificationService.requestPermission();
          await notificationService.cancelAppointmentReminder(updated.id);
          if (updated.reminderEnabled) {
            await notificationService.scheduleAppointmentReminder(updated);
          }
          navigator.pop(true);
        },
        onError: (failure) {
          setState(() {
            _submitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update: ${failure.message}')),
          );
        },
      );
    } else {
      final create = di.sl<CreateAppointment>();
      final result = await create(
        CreateAppointmentParams(
          dateTime: _selectedDateTime,
          hospitalName: hospitalName,
          doctorName: doctorName,
          speciality: speciality,
          remarks: remarks,
          location: location,
          reminderEnabled: _reminderEnabled,
          reminderMinutes: _reminderMinutes,
        ),
      );
      if (!mounted) return;
      result.fold(
        onSuccess: (appt) async {
          final notificationService = di.sl<NotificationService>();
          await notificationService.requestPermission();
          if (appt.reminderEnabled) {
            await notificationService.scheduleAppointmentReminder(appt);
          }
          navigator.pop(true);
        },
        onError: (failure) {
          setState(() {
            _submitting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save: ${failure.message}')),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Appointment' : 'New Appointment'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: AppConstants.defaultFontSize + 4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Reminder'),
                        subtitle: const Text('Notify before appointment'),
                        value: _reminderEnabled,
                        onChanged: (v) => setState(() => _reminderEnabled = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _reminderMinutes,
                        decoration: const InputDecoration(
                          labelText: 'Lead time',
                          border: OutlineInputBorder(),
                        ),
                        items: AppConstants.reminderOptionsMinutes
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(_formatLead(m)),
                              ),
                            )
                            .toList(),
                        onChanged: _reminderEnabled
                            ? (v) {
                                if (v != null) setState(() => _reminderMinutes = v);
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _doctorCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Doctor Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Doctor name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hospitalCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Hospital/Clinic',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Hospital/Clinic is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _specialityCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Speciality/Department (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location/Address (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _remarksCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Remarks/Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Date & Time',
                  style: TextStyle(
                    fontSize: AppConstants.defaultFontSize + 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selected'),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(_selectedDateTime),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _submitting ? null : _pickDateTime,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Pick'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _save,
                    icon: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _submitting ? 'Saving...' : 'Save',
                      style: const TextStyle(fontSize: AppConstants.defaultFontSize),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}/${dt.month}/${dt.year} • $h:$m $period';
  }

  String _formatLead(int minutes) {
    if (minutes >= 1440) return '${(minutes / 1440).round()} day before';
    if (minutes >= 60) return '${(minutes / 60).round()} hour(s) before';
    return '$minutes min before';
  }
}

