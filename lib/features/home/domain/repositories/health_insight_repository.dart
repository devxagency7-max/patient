import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/home/domain/entities/health_insight_entity.dart';

abstract class HealthInsightRepository {
  Future<ApiResult<HealthInsightEntity>> getHealthInsight();
}
