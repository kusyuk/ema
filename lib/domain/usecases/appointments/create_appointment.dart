import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

/// Parameters for creating an appointment
class CreateAppointmentParams {
  final DateTime dateTime;
  final String hospitalName;
  final String doctorName;
  final String? speciality;
  final String? remarks;
  final String? location;
   final bool reminderEnabled;
   final int reminderMinutes;

  const CreateAppointmentParams({
    required this.dateTime,
    required this.hospitalName,
    required this.doctorName,
    this.speciality,
    this.remarks,
    this.location,
    this.reminderEnabled = false,
    this.reminderMinutes = AppConstants.defaultReminderMinutes,
  });
}

/// Use case for creating a new appointment
class CreateAppointment implements UseCase<Appointment, CreateAppointmentParams> {
  final AppointmentRepository _repository;

  CreateAppointment(this._repository);

  @override
  Future<Result<Appointment>> call(CreateAppointmentParams params) async {
    final now = DateTime.now();
    final appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: params.dateTime,
      hospitalName: params.hospitalName,
      doctorName: params.doctorName,
      speciality: params.speciality,
      remarks: params.remarks,
      location: params.location,
      recordingIds: const [],
      createdAt: now,
      updatedAt: now,
      reminderEnabled: params.reminderEnabled,
      reminderMinutes: params.reminderMinutes,
    );

    return await _repository.createAppointment(appointment);
  }
}

