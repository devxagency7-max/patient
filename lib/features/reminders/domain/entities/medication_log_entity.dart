import 'package:equatable/equatable.dart';

class MedicationLogEntity extends Equatable {
  final String id;
  final String medicationPlanId;
  final DateTime scheduledAt;
  final int status;
  final DateTime? takenAt;
  final String? notes;

  const MedicationLogEntity({
    required this.id,
    required this.medicationPlanId,
    required this.scheduledAt,
    required this.status,
    this.takenAt,
    this.notes,
  });

  @override
  List<Object?> get props => [id, medicationPlanId, scheduledAt, status, takenAt, notes];
}

class AdherenceSummaryEntity extends Equatable {
  final int totalScheduled;
  final int totalTaken;
  final int totalMissed;
  final int totalSkipped;
  final double adherencePercentage;

  const AdherenceSummaryEntity({
    required this.totalScheduled,
    required this.totalTaken,
    required this.totalMissed,
    required this.totalSkipped,
    required this.adherencePercentage,
  });

  @override
  List<Object?> get props =>
      [totalScheduled, totalTaken, totalMissed, totalSkipped, adherencePercentage];
}
