import '../../core/utils/result.dart';
import '../entities/recording.dart';

/// Repository interface for recordings
abstract class RecordingRepository {
  Future<Result<List<Recording>>> getRecordings();
  Future<Result<Recording>> getRecordingById(String id);
  Future<Result<List<Recording>>> getRecordingsByAppointmentId(String appointmentId);
  Future<Result<Recording>> createRecording(Recording recording);
  Future<Result<Recording>> updateRecording(Recording recording);
  Future<Result<void>> deleteRecording(String id);
}

