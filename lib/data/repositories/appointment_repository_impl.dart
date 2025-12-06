import '../../core/utils/error_handler.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_local_data_source.dart';
import '../models/appointment_model.dart';

/// Implementation of appointment repository
class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentLocalDataSource _localDataSource;

  AppointmentRepositoryImpl(this._localDataSource);

  @override
  Future<Result<List<Appointment>>> getAppointments() async {
    try {
      final appointments = await _localDataSource.getAppointments();
      return Success(appointments);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }

  @override
  Future<Result<Appointment>> getAppointmentById(String id) async {
    try {
      final appointment = await _localDataSource.getAppointmentById(id);
      return Success(appointment);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }

  @override
  Future<Result<Appointment>> createAppointment(Appointment appointment) async {
    try {
      final model = AppointmentModel.fromEntity(appointment);
      final created = await _localDataSource.createAppointment(model);
      return Success(created);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }

  @override
  Future<Result<Appointment>> updateAppointment(Appointment appointment) async {
    try {
      final model = AppointmentModel.fromEntity(appointment);
      final updated = await _localDataSource.updateAppointment(model);
      return Success(updated);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }

  @override
  Future<Result<void>> deleteAppointment(String id) async {
    try {
      await _localDataSource.deleteAppointment(id);
      return const Success(null);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }

  @override
  Future<Result<List<Appointment>>> getAppointmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final appointments = await _localDataSource.getAppointmentsByDateRange(
        startDate,
        endDate,
      );
      return Success(appointments);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }

  @override
  Future<Result<List<Appointment>>> getUpcomingAppointments() async {
    try {
      final appointments = await _localDataSource.getUpcomingAppointments();
      return Success(appointments);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }
}

