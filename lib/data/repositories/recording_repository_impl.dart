import '../../core/utils/error_handler.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/recording.dart';
import '../../domain/repositories/recording_repository.dart';
import '../datasources/recording_local_data_source.dart';
import '../models/recording_model.dart';

/// Implementation of recording repository
class RecordingRepositoryImpl implements RecordingRepository {
  final RecordingLocalDataSource _localDataSource;

  RecordingRepositoryImpl(this._localDataSource);

  @override
  Future<Result<List<Recording>>> getRecordings() async {
    try {
      final recordings = await _localDataSource.getRecordings();
      return Success(recordings);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }

  @override
  Future<Result<Recording>> getRecordingById(String id) async {
    try {
      final recording = await _localDataSource.getRecordingById(id);
      return Success(recording);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }

  @override
  Future<Result<List<Recording>>> getRecordingsByAppointmentId(String appointmentId) async {
    try {
      final recordings = await _localDataSource.getRecordingsByAppointmentId(appointmentId);
      return Success(recordings);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }

  @override
  Future<Result<Recording>> createRecording(Recording recording) async {
    try {
      final model = RecordingModel.fromEntity(recording);
      final created = await _localDataSource.createRecording(model);
      return Success(created);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }

  @override
  Future<Result<Recording>> updateRecording(Recording recording) async {
    try {
      final model = RecordingModel.fromEntity(recording);
      final updated = await _localDataSource.updateRecording(model);
      return Success(updated);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }

  @override
  Future<Result<void>> deleteRecording(String id) async {
    try {
      await _localDataSource.deleteRecording(id);
      return const Success(null);
    } catch (e) {
      return Error(mapExceptionToFailure(e as Exception));
    }
  }
}

