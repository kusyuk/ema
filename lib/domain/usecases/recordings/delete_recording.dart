import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../repositories/recording_repository.dart';

/// Parameters for deleting a recording
class DeleteRecordingParams {
  final String id;

  const DeleteRecordingParams(this.id);
}

/// Use case for deleting a recording
class DeleteRecording implements UseCase<void, DeleteRecordingParams> {
  final RecordingRepository _repository;

  DeleteRecording(this._repository);

  @override
  Future<Result<void>> call(DeleteRecordingParams params) async {
    return await _repository.deleteRecording(params.id);
  }
}

