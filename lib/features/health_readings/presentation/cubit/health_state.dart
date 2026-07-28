import 'package:pharmacare/features/health_readings/domain/entities/health_reading_entity.dart';

sealed class HealthState {
  const HealthState();
}

class HealthInitial extends HealthState {
  const HealthInitial();
}

class HealthLoading extends HealthState {
  const HealthLoading();
}

class HealthSuccess extends HealthState {
  final HealthReadingEntity? newReading;
  final List<HealthReadingEntity>? readings;
  final List<HealthHistoryEntity>? history;

  const HealthSuccess({
    this.newReading,
    this.readings,
    this.history,
  });
}

class HealthError extends HealthState {
  final String message;
  const HealthError(this.message);
}
