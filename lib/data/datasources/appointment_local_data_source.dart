import 'package:hive/hive.dart';
import '../../core/errors/exceptions.dart';
import '../models/appointment_model.dart';
import '../utils/typedefs.dart';

/// Local data source for appointments
abstract class AppointmentLocalDataSource {
  Future<List<AppointmentModel>> getAppointments();
  Future<AppointmentModel> getAppointmentById(String id);
  Future<AppointmentModel> createAppointment(AppointmentModel appointment);
  Future<AppointmentModel> updateAppointment(AppointmentModel appointment);
  Future<void> deleteAppointment(String id);
  Future<List<AppointmentModel>> getAppointmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<AppointmentModel>> getUpcomingAppointments();
}

/// Implementation of appointment local data source
class AppointmentLocalDataSourceImpl implements AppointmentLocalDataSource {
  final Box<dynamic> _box;

  AppointmentLocalDataSourceImpl(this._box);

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final appointmentsJson = _box.get('appointments', defaultValue: <JsonMap>[]) as List<dynamic>;
      return appointmentsJson
          .map((json) => AppointmentModel.fromJson(json as JsonMap))
          .toList();
    } catch (e) {
      throw const CacheException('Failed to get appointments');
    }
  }

  @override
  Future<AppointmentModel> getAppointmentById(String id) async {
    try {
      final appointments = await getAppointments();
      final appointment = appointments.firstWhere(
        (apt) => apt.id == id,
        orElse: () => throw const CacheException('Appointment not found'),
      );
      return appointment;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to get appointment: ${e.toString()}');
    }
  }

  @override
  Future<AppointmentModel> createAppointment(AppointmentModel appointment) async {
    try {
      final appointments = await getAppointments();
      appointments.add(appointment);
      await _box.put('appointments', appointments.map((apt) => apt.toJson()).toList());
      return appointment;
    } catch (e) {
      throw CacheException('Failed to create appointment: ${e.toString()}');
    }
  }

  @override
  Future<AppointmentModel> updateAppointment(AppointmentModel appointment) async {
    try {
      final appointments = await getAppointments();
      final index = appointments.indexWhere((apt) => apt.id == appointment.id);
      if (index == -1) {
        throw const CacheException('Appointment not found');
      }
      appointments[index] = appointment;
      await _box.put('appointments', appointments.map((apt) => apt.toJson()).toList());
      return appointment;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to update appointment: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAppointment(String id) async {
    try {
      final appointments = await getAppointments();
      appointments.removeWhere((apt) => apt.id == id);
      await _box.put('appointments', appointments.map((apt) => apt.toJson()).toList());
    } catch (e) {
      throw CacheException('Failed to delete appointment: ${e.toString()}');
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final appointments = await getAppointments();
      return appointments.where((apt) {
        return apt.dateTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
            apt.dateTime.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw CacheException('Failed to get appointments by date range: ${e.toString()}');
    }
  }

  @override
  Future<List<AppointmentModel>> getUpcomingAppointments() async {
    try {
      final appointments = await getAppointments();
      final now = DateTime.now();
      return appointments
          .where((apt) => apt.dateTime.isAfter(now))
          .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } catch (e) {
      throw CacheException('Failed to get upcoming appointments: ${e.toString()}');
    }
  }
}

