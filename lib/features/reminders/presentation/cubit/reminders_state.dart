import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/reminders/domain/entities/medication_plan_entity.dart';
import 'package:pharmacare/features/reminders/domain/entities/reminder_entity.dart';

abstract class RemindersState extends Equatable {
  const RemindersState();

  @override
  List<Object?> get props => [];
}

class RemindersInitial extends RemindersState {}

class RemindersLoading extends RemindersState {}

class RemindersLoaded extends RemindersState {
  final List<ReminderEntity> reminders;
  final List<MedicationPlanEntity> medicationPlans;

  const RemindersLoaded({required this.reminders, required this.medicationPlans});

  @override
  List<Object?> get props => [reminders, medicationPlans];
}

class RemindersOperationSuccess extends RemindersState {
  final String message;

  const RemindersOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RemindersError extends RemindersState {
  final String message;

  const RemindersError(this.message);

  @override
  List<Object?> get props => [message];
}
