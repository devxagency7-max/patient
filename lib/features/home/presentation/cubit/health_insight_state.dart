import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/home/domain/entities/health_insight_entity.dart';

abstract class HealthInsightState extends Equatable {
  const HealthInsightState();

  @override
  List<Object?> get props => [];
}

class HealthInsightInitial extends HealthInsightState {}

class HealthInsightLoading extends HealthInsightState {}

class HealthInsightLoaded extends HealthInsightState {
  final HealthInsightEntity insight;

  const HealthInsightLoaded(this.insight);

  @override
  List<Object?> get props => [insight];
}

class HealthInsightError extends HealthInsightState {
  final String message;

  const HealthInsightError(this.message);

  @override
  List<Object?> get props => [message];
}
