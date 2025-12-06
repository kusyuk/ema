import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../repositories/appointment_repository.dart';

/// Parameters for deleting an appointment
class DeleteAppointmentParams {
  final String id;

  const DeleteAppointmentParams(this.id);
}

/// Use case for deleting an appointment
class DeleteAppointment implements UseCase<void, DeleteAppointmentParams> {
  final AppointmentRepository _repository;

  DeleteAppointment(this._repository);

  @override
  Future<Result<void>> call(DeleteAppointmentParams params) async {
    return await _repository.deleteAppointment(params.id);
  }
}

