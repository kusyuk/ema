import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../entities/recording.dart';
import '../../repositories/recording_repository.dart';

/// Parameters for updating a recording
class UpdateRecordingParams {
  final Recording recording;

  const UpdateRecordingParams(this.recording);
}

/// Use case for updating a recording
class UpdateRecording implements UseCase<Recording, UpdateRecordingParams> {
  final RecordingRepository _repository;

  UpdateRecording(this._repository);

  @override
  Future<Result<Recording>> call(UpdateRecordingParams params) async {
    return await _repository.updateRecording(params.recording);
  }
}

