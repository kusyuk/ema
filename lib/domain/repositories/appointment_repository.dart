import '../entities/appointment.dart';

/// Repository interface for appointments
abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments();
  Future<Appointment> getAppointmentById(String id);
  Future<Appointment> createAppointment(Appointment appointment);
  Future<Appointment> updateAppointment(Appointment appointment);
  Future<void> deleteAppointment(String id);
  Future<List<Appointment>> getAppointmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<Appointment>> getUpcomingAppointments();
}

