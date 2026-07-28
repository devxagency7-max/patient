import 'package:equatable/equatable.dart';

class MedicationPlanEntity extends Equatable {
  final String id;
  final String medicineName;
  final String dosage;
  final String instructions;
  final List<MedicationScheduleEntity> schedules;

  const MedicationPlanEntity({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.instructions,
    required this.schedules,
  });

  @override
  List<Object?> get props => [id, medicineName, dosage, instructions, schedules];
}

class MedicationScheduleEntity extends Equatable {
  final String timeOfDay; // Morning, Afternoon, Evening
  final String frequency; // Daily, Weekly
  final String startDate;
  final String? endDate;

  const MedicationScheduleEntity({
    required this.timeOfDay,
    required this.frequency,
    required this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [timeOfDay, frequency, startDate, endDate];
}
