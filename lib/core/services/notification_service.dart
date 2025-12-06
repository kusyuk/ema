import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../utils/logger.dart';
import '../../domain/entities/appointment.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    final String localTz = DateTime.now().timeZoneName;
    try {
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(initSettings);

    const androidChannel = AndroidNotificationChannel(
      'reminders',
      'Reminders',
      description: 'Appointment reminders',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return (android ?? true) && (ios ?? true);
  }

  int _idForAppointment(String appointmentId) {
    return appointmentId.hashCode & 0x7fffffff;
  }

  Future<void> scheduleAppointmentReminder(Appointment appt) async {
    if (!_initialized) await initialize();
    if (!appt.reminderEnabled) return;

    final scheduled = appt.dateTime.subtract(Duration(minutes: appt.reminderMinutes));
    if (scheduled.isBefore(DateTime.now())) {
      Logger.info('Reminder time already passed; skipping schedule');
      return;
    }

    final tzTime = tz.TZDateTime.from(scheduled, tz.local);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminders',
        'Reminders',
        channelDescription: 'Appointment reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      _idForAppointment(appt.id),
      'Appointment reminder',
      '${appt.doctorName.isNotEmpty ? appt.doctorName : appt.hospitalName} at ${_formatTime(appt.dateTime)}',
      tzTime,
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelAppointmentReminder(String appointmentId) async {
    if (!_initialized) await initialize();
    await _plugin.cancel(_idForAppointment(appointmentId));
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

