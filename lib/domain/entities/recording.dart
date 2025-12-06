import 'package:equatable/equatable.dart';

/// Recording entity
class Recording extends Equatable {
  final String id;
  final String appointmentId;
  final String audioFilePath;
  final String? rawTranscription;
  final String? summarizedTranscription;
  final Duration duration;
  final DateTime createdAt;
  final String language;

  const Recording({
    required this.id,
    required this.appointmentId,
    required this.audioFilePath,
    this.rawTranscription,
    this.summarizedTranscription,
    required this.duration,
    required this.createdAt,
    this.language = 'en',
  });

  @override
  List<Object?> get props => [
        id,
        appointmentId,
        audioFilePath,
        rawTranscription,
        summarizedTranscription,
        duration,
        createdAt,
        language,
      ];

  /// Create a copy with updated fields
  Recording copyWith({
    String? id,
    String? appointmentId,
    String? audioFilePath,
    String? rawTranscription,
    String? summarizedTranscription,
    Duration? duration,
    DateTime? createdAt,
    String? language,
  }) {
    return Recording(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      rawTranscription: rawTranscription ?? this.rawTranscription,
      summarizedTranscription: summarizedTranscription ?? this.summarizedTranscription,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      language: language ?? this.language,
    );
  }
}

