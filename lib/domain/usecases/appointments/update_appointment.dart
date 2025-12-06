import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

/// Parameters for updating an appointment
class UpdateAppointmentParams {
  final Appointment appointment;

  const UpdateAppointmentParams(this.appointment);
}

/// Use case for updating an appointment
class UpdateAppointment implements UseCase<Appointment, UpdateAppointmentParams> {
  final AppointmentRepository _repository;

  UpdateAppointment(this._repository);

  @override
  Future<Result<Appointment>> call(UpdateAppointmentParams params) async {
    final updatedAppointment = params.appointment.copyWith(
      updatedAt: DateTime.now(),
    );
    return await _repository.updateAppointment(updatedAppointment);
  }
}

