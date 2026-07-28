import 'package:equatable/equatable.dart';

class ReminderEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String adjustedTime; // DateTimeOffset ISO string
  final String status; // Pending, Taken, Skipped, Snoozed
  final String? relatedEntityId;

  const ReminderEntity({
    required this.id,
    required this.title,
    this.description,
    required this.adjustedTime,
    required this.status,
    this.relatedEntityId,
  });

  @override
  List<Object?> get props => [id, title, description, adjustedTime, status, relatedEntityId];
}
