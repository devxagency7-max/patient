import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/reminders/domain/entities/medication_log_entity.dart';

abstract class AdherenceState extends Equatable {
  const AdherenceState();

  @override
  List<Object?> get props => [];
}

class AdherenceInitial extends AdherenceState {}

class AdherenceLoading extends AdherenceState {}

class AdherenceLoaded extends AdherenceState {
  final AdherenceSummaryEntity summary;
  final List<MedicationLogEntity> logs;

  const AdherenceLoaded({required this.summary, required this.logs});

  @override
  List<Object?> get props => [summary, logs];
}

class AdherenceError extends AdherenceState {
  final String message;

  const AdherenceError(this.message);

  @override
  List<Object?> get props => [message];
}
