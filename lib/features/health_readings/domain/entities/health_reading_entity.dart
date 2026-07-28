import 'package:equatable/equatable.dart';

class HealthReadingEntity extends Equatable {
  final String id;
  final String userId;
  final String type; // BloodPressure, Sugar, Weight
  final double value;
  final String? notes;
  final String createdAt;

  const HealthReadingEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.value,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, type, value, notes, createdAt];
}

class HealthHistoryEntity extends Equatable {
  final String type;
  final int totalReadings;
  final double latestValue;
  final String latestReadingAt;
  final double minValue;
  final double maxValue;
  final double averageValue;
  final List<HealthReadingEntity> recentReadings;

  const HealthHistoryEntity({
    required this.type,
    required this.totalReadings,
    required this.latestValue,
    required this.latestReadingAt,
    required this.minValue,
    required this.maxValue,
    required this.averageValue,
    required this.recentReadings,
  });

  @override
  List<Object?> get props => [
        type,
        totalReadings,
        latestValue,
        latestReadingAt,
        minValue,
        maxValue,
        averageValue,
        recentReadings,
      ];
}
