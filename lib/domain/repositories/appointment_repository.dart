import '../../core/utils/result.dart';
import '../entities/appointment.dart';

/// Repository interface for appointments
abstract class AppointmentRepository {
  Future<Result<List<Appointment>>> getAppointments();
  Future<Result<Appointment>> getAppointmentById(String id);
  Future<Result<Appointment>> createAppointment(Appointment appointment);
  Future<Result<Appointment>> updateAppointment(Appointment appointment);
  Future<Result<void>> deleteAppointment(String id);
  Future<Result<List<Appointment>>> getAppointmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<Result<List<Appointment>>> getUpcomingAppointments();
}

