import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../entities/recording.dart';
import '../../repositories/recording_repository.dart';

/// Parameters for getting recordings by appointment ID
class GetRecordingsByAppointmentParams {
  final String appointmentId;

  const GetRecordingsByAppointmentParams(this.appointmentId);
}

/// Use case for getting recordings by appointment ID
class GetRecordingsByAppointment implements UseCase<List<Recording>, GetRecordingsByAppointmentParams> {
  final RecordingRepository _repository;

  GetRecordingsByAppointment(this._repository);

  @override
  Future<Result<List<Recording>>> call(GetRecordingsByAppointmentParams params) async {
    return await _repository.getRecordingsByAppointmentId(params.appointmentId);
  }
}

