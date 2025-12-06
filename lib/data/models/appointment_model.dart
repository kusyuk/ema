import '../../domain/entities/appointment.dart';
import '../utils/typedefs.dart';

/// Appointment data model
class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.dateTime,
    required super.hospitalName,
    required super.doctorName,
    super.speciality,
    super.remarks,
    super.location,
    super.recordingIds,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from JSON
  factory AppointmentModel.fromJson(JsonMap json) {
    return AppointmentModel(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      hospitalName: json['hospitalName'] as String,
      doctorName: json['doctorName'] as String,
      speciality: json['speciality'] as String?,
      remarks: json['remarks'] as String?,
      location: json['location'] as String?,
      recordingIds: (json['recordingIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  JsonMap toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'hospitalName': hospitalName,
      'doctorName': doctorName,
      'speciality': speciality,
      'remarks': remarks,
      'location': location,
      'recordingIds': recordingIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from entity
  factory AppointmentModel.fromEntity(Appointment appointment) {
    return AppointmentModel(
      id: appointment.id,
      dateTime: appointment.dateTime,
      hospitalName: appointment.hospitalName,
      doctorName: appointment.doctorName,
      speciality: appointment.speciality,
      remarks: appointment.remarks,
      location: appointment.location,
      recordingIds: appointment.recordingIds,
      createdAt: appointment.createdAt,
      updatedAt: appointment.updatedAt,
    );
  }
}

