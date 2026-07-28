import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/health_readings/domain/entities/health_reading_entity.dart';

abstract class HealthRepository {
  Future<ApiResult<HealthReadingEntity>> addHealthReading({
    required String type,
    required double value,
    required DateTime recordedAt,
  });

  Future<ApiResult<List<HealthReadingEntity>>> getHealthReadings({
    int page = 1,
    int pageSize = 20,
  });

  Future<ApiResult<List<HealthHistoryEntity>>> getHealthHistory();
}
