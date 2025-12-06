import '../entities/recording.dart';

/// Repository interface for recordings
abstract class RecordingRepository {
  Future<List<Recording>> getRecordings();
  Future<Recording> getRecordingById(String id);
  Future<List<Recording>> getRecordingsByAppointmentId(String appointmentId);
  Future<Recording> createRecording(Recording recording);
  Future<Recording> updateRecording(Recording recording);
  Future<void> deleteRecording(String id);
}

