import 'package:hive/hive.dart';
import '../../core/errors/exceptions.dart';
import '../models/recording_model.dart';
import '../utils/typedefs.dart';

/// Local data source for recordings
abstract class RecordingLocalDataSource {
  Future<List<RecordingModel>> getRecordings();
  Future<RecordingModel> getRecordingById(String id);
  Future<List<RecordingModel>> getRecordingsByAppointmentId(String appointmentId);
  Future<RecordingModel> createRecording(RecordingModel recording);
  Future<RecordingModel> updateRecording(RecordingModel recording);
  Future<void> deleteRecording(String id);
}

/// Implementation of recording local data source
class RecordingLocalDataSourceImpl implements RecordingLocalDataSource {
  final Box<dynamic> _box;

  RecordingLocalDataSourceImpl(this._box);

  @override
  Future<List<RecordingModel>> getRecordings() async {
    try {
      final recordingsJson = _box.get('recordings', defaultValue: <JsonMap>[]) as List<dynamic>;
      return recordingsJson
          .map((json) {
            // Convert Hive's _Map<dynamic, dynamic> to Map<String, dynamic>
            if (json is Map) {
              return RecordingModel.fromJson(Map<String, dynamic>.from(json));
            }
            throw const CacheException('Invalid recording data format');
          })
          .toList();
    } catch (e) {
      throw CacheException('Failed to get recordings: ${e.toString()}');
    }
  }

  @override
  Future<RecordingModel> getRecordingById(String id) async {
    try {
      final recordings = await getRecordings();
      final recording = recordings.firstWhere(
        (rec) => rec.id == id,
        orElse: () => throw const CacheException('Recording not found'),
      );
      return recording;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to get recording: ${e.toString()}');
    }
  }

  @override
  Future<List<RecordingModel>> getRecordingsByAppointmentId(String appointmentId) async {
    try {
      final recordings = await getRecordings();
      return recordings
          .where((rec) => rec.appointmentId == appointmentId)
          .toList();
    } catch (e) {
      throw CacheException('Failed to get recordings by appointment: ${e.toString()}');
    }
  }

  @override
  Future<RecordingModel> createRecording(RecordingModel recording) async {
    try {
      final recordings = await getRecordings();
      recordings.add(recording);
      await _box.put('recordings', recordings.map((rec) => rec.toJson()).toList());
      return recording;
    } catch (e) {
      throw CacheException('Failed to create recording: ${e.toString()}');
    }
  }

  @override
  Future<RecordingModel> updateRecording(RecordingModel recording) async {
    try {
      final recordings = await getRecordings();
      final index = recordings.indexWhere((rec) => rec.id == recording.id);
      if (index == -1) {
        throw const CacheException('Recording not found');
      }
      recordings[index] = recording;
      await _box.put('recordings', recordings.map((rec) => rec.toJson()).toList());
      return recording;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to update recording: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteRecording(String id) async {
    try {
      final recordings = await getRecordings();
      recordings.removeWhere((rec) => rec.id == id);
      await _box.put('recordings', recordings.map((rec) => rec.toJson()).toList());
    } catch (e) {
      throw CacheException('Failed to delete recording: ${e.toString()}');
    }
  }
}

