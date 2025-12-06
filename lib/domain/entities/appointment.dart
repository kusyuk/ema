import 'package:equatable/equatable.dart';

/// Appointment entity
class Appointment extends Equatable {
  final String id;
  final DateTime dateTime;
  final String hospitalName;
  final String doctorName;
  final String? speciality;
  final String? remarks;
  final String? location;
  final List<String> recordingIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool reminderEnabled;
  final int reminderMinutes;

  const Appointment({
    required this.id,
    required this.dateTime,
    required this.hospitalName,
    required this.doctorName,
    this.speciality,
    this.remarks,
    this.location,
    this.recordingIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.reminderEnabled = false,
    this.reminderMinutes = 60,
  });

  @override
  List<Object?> get props => [
        id,
        dateTime,
        hospitalName,
        doctorName,
        speciality,
        remarks,
        location,
        recordingIds,
        createdAt,
        updatedAt,
        reminderEnabled,
        reminderMinutes,
      ];

  /// Create a copy with updated fields
  Appointment copyWith({
    String? id,
    DateTime? dateTime,
    String? hospitalName,
    String? doctorName,
    String? speciality,
    String? remarks,
    String? location,
    List<String>? recordingIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? reminderEnabled,
    int? reminderMinutes,
  }) {
    return Appointment(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      hospitalName: hospitalName ?? this.hospitalName,
      doctorName: doctorName ?? this.doctorName,
      speciality: speciality ?? this.speciality,
      remarks: remarks ?? this.remarks,
      location: location ?? this.location,
      recordingIds: recordingIds ?? this.recordingIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }
}

