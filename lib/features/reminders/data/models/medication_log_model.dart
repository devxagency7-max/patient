import 'package:pharmacare/features/reminders/domain/entities/medication_log_entity.dart';

class MedicationLogModel extends MedicationLogEntity {
  const MedicationLogModel({
    required super.id,
    required super.medicationPlanId,
    required super.scheduledAt,
    required super.status,
    super.takenAt,
    super.notes,
  });

  factory MedicationLogModel.fromJson(Map<String, dynamic> json) {
    return MedicationLogModel(
      id: json['id'] as String? ?? '',
      medicationPlanId: json['medicationPlanId'] as String? ?? '',
      scheduledAt: DateTime.tryParse(json['scheduledAt'] as String? ?? '') ?? DateTime.now(),
      status: json['status'] as int? ?? 0,
      takenAt: json['takenAt'] != null ? DateTime.tryParse(json['takenAt'] as String) : null,
      notes: json['notes'] as String?,
    );
  }
}

class AdherenceSummaryModel extends AdherenceSummaryEntity {
  const AdherenceSummaryModel({
    required super.totalScheduled,
    required super.totalTaken,
    required super.totalMissed,
    required super.totalSkipped,
    required super.adherencePercentage,
  });

  factory AdherenceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AdherenceSummaryModel(
      totalScheduled: json['totalScheduled'] as int? ?? 0,
      totalTaken: json['totalTaken'] as int? ?? 0,
      totalMissed: json['totalMissed'] as int? ?? 0,
      totalSkipped: json['totalSkipped'] as int? ?? 0,
      adherencePercentage: (json['adherencePercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
