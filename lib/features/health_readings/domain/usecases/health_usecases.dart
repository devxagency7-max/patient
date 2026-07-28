import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/health_readings/domain/entities/health_reading_entity.dart';
import 'package:pharmacare/features/health_readings/domain/repositories/health_repository.dart';

class AddHealthReadingUseCase {
  final HealthRepository repository;

  AddHealthReadingUseCase(this.repository);

  Future<ApiResult<HealthReadingEntity>> call({
    required String type,
    required double value,
    required DateTime recordedAt,
  }) {
    return repository.addHealthReading(
      type: type,
      value: value,
      recordedAt: recordedAt,
    );
  }
}

class GetHealthReadingsUseCase {
  final HealthRepository repository;

  GetHealthReadingsUseCase(this.repository);

  Future<ApiResult<List<HealthReadingEntity>>> call({
    int page = 1,
    int pageSize = 20,
  }) {
    return repository.getHealthReadings(page: page, pageSize: pageSize);
  }
}

class GetHealthHistoryUseCase {
  final HealthRepository repository;

  GetHealthHistoryUseCase(this.repository);

  Future<ApiResult<List<HealthHistoryEntity>>> call() {
    return repository.getHealthHistory();
  }
}
