import 'package:pharmacare/features/health_readings/domain/entities/health_reading_entity.dart';

class HealthReadingModel extends HealthReadingEntity {
  const HealthReadingModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.value,
    super.notes,
    required super.createdAt,
  });

  factory HealthReadingModel.fromJson(Map<String, dynamic> json) {
    return HealthReadingModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'value': value,
      'notes': notes,
      'createdAt': createdAt,
    };
  }
}

class HealthHistoryModel extends HealthHistoryEntity {
  const HealthHistoryModel({
    required super.type,
    required super.totalReadings,
    required super.latestValue,
    required super.latestReadingAt,
    required super.minValue,
    required super.maxValue,
    required super.averageValue,
    required super.recentReadings,
  });

  factory HealthHistoryModel.fromJson(Map<String, dynamic> json) {
    return HealthHistoryModel(
      type: json['type'] as String? ?? '',
      totalReadings: json['totalReadings'] as int? ?? 0,
      latestValue: (json['latestValue'] as num?)?.toDouble() ?? 0.0,
      latestReadingAt: json['latestReadingAt'] as String? ?? '',
      minValue: (json['minValue'] as num?)?.toDouble() ?? 0.0,
      maxValue: (json['maxValue'] as num?)?.toDouble() ?? 0.0,
      averageValue: (json['averageValue'] as num?)?.toDouble() ?? 0.0,
      recentReadings: (json['recentReadings'] as List<dynamic>?)
              ?.map((e) => HealthReadingModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
