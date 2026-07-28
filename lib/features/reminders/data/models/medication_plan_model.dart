import 'package:pharmacare/features/reminders/domain/entities/medication_plan_entity.dart';

class MedicationPlanModel extends MedicationPlanEntity {
  const MedicationPlanModel({
    required super.id,
    required super.medicineName,
    required super.dosage,
    required super.instructions,
    required List<MedicationScheduleModel> super.schedules,
  });

  factory MedicationPlanModel.fromJson(Map<String, dynamic> json) {
    var list = json['schedules'] as List? ?? [];
    List<MedicationScheduleModel> schedulesModels = list.map((e) => MedicationScheduleModel.fromJson(e as Map<String, dynamic>)).toList();

    return MedicationPlanModel(
      id: json['id'] as String,
      medicineName: json['medicineName'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      schedules: schedulesModels,
    );
  }
}

class MedicationScheduleModel extends MedicationScheduleEntity {
  const MedicationScheduleModel({
    required super.timeOfDay,
    required super.frequency,
    required super.startDate,
    super.endDate,
  });

  factory MedicationScheduleModel.fromJson(Map<String, dynamic> json) {
    return MedicationScheduleModel(
      timeOfDay: json['timeOfDay'] as String? ?? 'Morning',
      frequency: json['frequency'] as String? ?? 'Daily',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String?,
    );
  }
}
