import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

/// Parameters for getting appointment by ID
class GetAppointmentByIdParams {
  final String id;

  const GetAppointmentByIdParams(this.id);
}

/// Use case for getting an appointment by ID
class GetAppointmentById implements UseCase<Appointment, GetAppointmentByIdParams> {
  final AppointmentRepository _repository;

  GetAppointmentById(this._repository);

  @override
  Future<Result<Appointment>> call(GetAppointmentByIdParams params) async {
    return await _repository.getAppointmentById(params.id);
  }
}

