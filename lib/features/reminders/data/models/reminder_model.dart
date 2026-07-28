import 'package:pharmacare/features/reminders/domain/entities/reminder_entity.dart';

class ReminderModel extends ReminderEntity {
  const ReminderModel({
    required super.id,
    required super.title,
    super.description,
    required super.adjustedTime,
    required super.status,
    super.relatedEntityId,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      adjustedTime: json['adjustedTime'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      relatedEntityId: json['relatedEntityId'] as String?,
    );
  }
}
