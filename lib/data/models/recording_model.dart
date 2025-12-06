import '../../domain/entities/recording.dart';
import '../utils/typedefs.dart';

/// Recording data model
class RecordingModel extends Recording {
  const RecordingModel({
    required super.id,
    required super.appointmentId,
    required super.audioFilePath,
    super.rawTranscription,
    super.summarizedTranscription,
    required super.duration,
    required super.createdAt,
    super.language,
  });

  /// Create from JSON
  factory RecordingModel.fromJson(JsonMap json) {
    return RecordingModel(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      audioFilePath: json['audioFilePath'] as String,
      rawTranscription: json['rawTranscription'] as String?,
      summarizedTranscription: json['summarizedTranscription'] as String?,
      duration: Duration(milliseconds: json['duration'] as int),
      createdAt: DateTime.parse(json['createdAt'] as String),
      language: json['language'] as String? ?? 'en',
    );
  }

  /// Convert to JSON
  JsonMap toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'audioFilePath': audioFilePath,
      'rawTranscription': rawTranscription,
      'summarizedTranscription': summarizedTranscription,
      'duration': duration.inMilliseconds,
      'createdAt': createdAt.toIso8601String(),
      'language': language,
    };
  }

  /// Create from entity
  factory RecordingModel.fromEntity(Recording recording) {
    return RecordingModel(
      id: recording.id,
      appointmentId: recording.appointmentId,
      audioFilePath: recording.audioFilePath,
      rawTranscription: recording.rawTranscription,
      summarizedTranscription: recording.summarizedTranscription,
      duration: recording.duration,
      createdAt: recording.createdAt,
      language: recording.language,
    );
  }
}

