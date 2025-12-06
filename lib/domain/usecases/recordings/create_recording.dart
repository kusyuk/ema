import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../entities/recording.dart';
import '../../repositories/recording_repository.dart';

/// Parameters for creating a recording
class CreateRecordingParams {
  final String appointmentId;
  final String audioFilePath;
  final Duration duration;
  final String language;

  const CreateRecordingParams({
    required this.appointmentId,
    required this.audioFilePath,
    required this.duration,
    this.language = 'en',
  });
}

/// Use case for creating a new recording
class CreateRecording implements UseCase<Recording, CreateRecordingParams> {
  final RecordingRepository _repository;

  CreateRecording(this._repository);

  @override
  Future<Result<Recording>> call(CreateRecordingParams params) async {
    final recording = Recording(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      appointmentId: params.appointmentId,
      audioFilePath: params.audioFilePath,
      duration: params.duration,
      createdAt: DateTime.now(),
      language: params.language,
    );

    return await _repository.createRecording(recording);
  }
}

