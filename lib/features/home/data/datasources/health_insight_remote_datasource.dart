import 'package:pharmacare/features/home/data/models/health_insight_model.dart';

abstract class HealthInsightRemoteDataSource {
  Future<HealthInsightModel> getHealthInsight();
}
