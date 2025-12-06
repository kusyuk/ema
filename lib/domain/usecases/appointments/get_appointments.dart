import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

/// Use case for getting all appointments
class GetAppointments implements UseCaseNoParams<List<Appointment>> {
  final AppointmentRepository _repository;

  GetAppointments(this._repository);

  @override
  Future<Result<List<Appointment>>> call() async {
    return await _repository.getAppointments();
  }
}

