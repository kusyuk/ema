import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/utils/result.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/usecases/appointments/get_appointments.dart';
import 'appointment_form_page.dart';
import 'appointment_detail_page.dart';
import 'recording_page.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/refresh_service.dart';

class CalendarHomePage extends StatefulWidget {
  const CalendarHomePage({super.key});

  @override
  State<CalendarHomePage> createState() => CalendarHomePageState();
}

class CalendarHomePageState extends State<CalendarHomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  bool _loading = true;
  String? _error;
  Map<DateTime, List<Appointment>> _eventMap = {};

  final Duration _recordingWindow = const Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    di.sl<RefreshService>().addListener(_onRefresh);
  }

  @override
  void dispose() {
    di.sl<RefreshService>().removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    if (mounted) {
      _loadAppointments();
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final getAppointments = di.sl<GetAppointments>();
    final result = await getAppointments();

    if (!mounted) return;

    result.fold(
      onSuccess: (data) {
        final map = <DateTime, List<Appointment>>{};
        for (final appt in data) {
          final key = DateTime(
            appt.dateTime.year,
            appt.dateTime.month,
            appt.dateTime.day,
          );
          map.putIfAbsent(key, () => []).add(appt);
        }
        setState(() {
          _eventMap = map;
          _loading = false;
        });
      },
      onError: (failure) {
        setState(() {
          _error = failure.message;
          _loading = false;
        });
      },
    );
  }

  Future<void> createAppointment() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AppointmentFormPage()),
    );
    if (created == true && mounted) {
      await _loadAppointments();
    }
  }

  List<Appointment> _eventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _eventMap[key] ?? [];
  }

  bool _isWithinRecordingWindow(Appointment appt) {
    final now = DateTime.now();
    final start = appt.dateTime.subtract(_recordingWindow);
    final end = appt.dateTime.add(_recordingWindow);
    return now.isAfter(start) && now.isBefore(end);
  }

  bool _isPastSelectedDay() {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return _selectedDay.isBefore(today);
  }

  String? _reminderLeadText(Appointment? appt) {
    if (appt == null) return null;
    final minutes = appt.reminderMinutes;
    if (minutes >= 1440) {
      return 'Recording available within ${minutes ~/ 1440} day(s) of an appointment.';
    }
    if (minutes >= 60) {
      return 'Recording available within ${minutes ~/ 60} hour(s) of an appointment.';
    }
    if (minutes > 0) {
      return 'Recording available within $minutes minutes of an appointment.';
    }
    return 'Recording available before appointment.';
  }

  String _reminderLeadTextForSelection(List<Appointment> appts) {
    if (appts.isEmpty) {
      return 'Recording available before appointment.';
    }
    // Use the minimum reminder among the selected day appointments
    final minutes = appts
        .map((a) => a.reminderMinutes)
        .reduce((a, b) => a < b ? a : b);
    return _reminderLeadText(
          Appointment(
            id: '',
            dateTime: DateTime.now(),
            hospitalName: '',
            doctorName: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            reminderEnabled: true,
            reminderMinutes: minutes,
          ),
        ) ??
        'Recording available before appointment.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(fontSize: AppConstants.defaultFontSize),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error ?? 'Error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAppointments,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final selectedEvents = _eventsForDay(_selectedDay);

    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final isPast = _selectedDay.isBefore(today);
    final startable = isPast
        ? <Appointment>[]
        : selectedEvents.where(_isWithinRecordingWindow).toList();
    final Appointment? startableAppt = startable.isNotEmpty
        ? startable.first
        : null;

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.iconDefault,
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Card(
                  color: AppTheme.surfaceLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TableCalendar<Appointment>(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2030),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(day, _selectedDay),
                      eventLoader: _eventsForDay,
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      sixWeekMonthsEnforced: true,
                      rowHeight: 42,
                      daysOfWeekHeight: 20,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        defaultTextStyle: TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontSize: 14,
                        ),
                        weekendTextStyle: TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontSize: 14,
                        ),
                        outsideTextStyle: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: AppTheme.primaryDark,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: AppTheme.textSecondary,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSelectedDayCard(selectedEvents, startableAppt),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.primaryLight,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => createAppointment(),
              child: const Text(
                'Add New Appointment',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayCard(
    List<Appointment> appointments,
    Appointment? startableAppt,
  ) {
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final title = appointments.isEmpty
        ? 'No appointments on ${_formatDate(_selectedDay)}'
        : isToday
        ? 'Today\'s appointments'
        : 'Appointments on ${_formatDate(_selectedDay)}';

    final isPast = _isPastSelectedDay();

    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textOnDark,
              ),
            ),
            const SizedBox(height: 12),
            if (startableAppt != null)
              Semantics(
                label: 'Record session for selected appointment',
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              RecordingPage(appointmentId: startableAppt.id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: AppTheme.primaryLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Record Session'),
                  ),
                ),
              )
            else if (!isPast)
              Text(
                _reminderLeadTextForSelection(appointments),
                style: const TextStyle(color: AppTheme.textSecondaryOnDark),
              ),
            const SizedBox(height: 12),
            if (appointments.isEmpty)
              const Text(
                'No appointments',
                style: TextStyle(color: AppTheme.textOnDark),
              )
            else
              Column(
                children: appointments
                    .map(
                      (appt) => Semantics(
                        label:
                            'Appointment with ${appt.doctorName.isEmpty ? appt.hospitalName : appt.doctorName} at ${_formatTime(appt.dateTime)}',
                        button: true,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event_note),
                          title: Text(
                            appt.doctorName.isEmpty
                                ? appt.hospitalName
                                : appt.doctorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textOnDark,
                            ),
                          ),
                          subtitle: Text(
                            '${appt.hospitalName}\n${_formatTime(appt.dateTime)}',
                            style: const TextStyle(
                              color: AppTheme.textSecondaryOnDark,
                            ),
                          ),
                          isThreeLine: true,
                          onTap: () async {
                            final changed = await Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) => AppointmentDetailPage(
                                      appointmentId: appt.id,
                                    ),
                                  ),
                                );
                            if (changed == true && mounted) {
                              _loadAppointments();
                            }
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
