import '../../../../core/utils/result.dart';
import '../../../../core/utils/usecase.dart';
import '../../../../core/utils/file_storage.dart';
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
    // Enforce one-recording-per-appointment: replace existing if present
    final existingResult =
        await _repository.getRecordingsByAppointmentId(params.appointmentId);

    return await existingResult.fold(
      onSuccess: (list) async {
        if (list.isNotEmpty) {
          final existing = list.first;
          // Delete old audio file
          try {
            await FileStorage.deleteAudioFile(existing.audioFilePath);
          } catch (_) {}

          final updated = existing.copyWith(
            audioFilePath: params.audioFilePath,
            duration: params.duration,
            language: params.language,
            createdAt: DateTime.now(),
          );
          return await _repository.updateRecording(updated);
        } else {
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
      },
      onError: (_) async {
        // Fallback: create new if lookup failed
        final recording = Recording(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          appointmentId: params.appointmentId,
          audioFilePath: params.audioFilePath,
          duration: params.duration,
          createdAt: DateTime.now(),
          language: params.language,
        );
        return await _repository.createRecording(recording);
      },
    );
  }
}

