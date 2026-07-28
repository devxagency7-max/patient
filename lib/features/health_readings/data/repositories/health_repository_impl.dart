import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/health_readings/data/datasources/health_remote_datasource.dart';
import 'package:pharmacare/features/health_readings/domain/entities/health_reading_entity.dart';
import 'package:pharmacare/features/health_readings/domain/repositories/health_repository.dart';

class HealthRepositoryImpl implements HealthRepository {
  final HealthRemoteDataSource remoteDataSource;

  HealthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<HealthReadingEntity>> addHealthReading({
    required String type,
    required double value,
    required DateTime recordedAt,
  }) async {
    try {
      final model = await remoteDataSource.addHealthReading(
        type: type,
        value: value,
        recordedAt: recordedAt,
      );
      return ApiSuccess(model);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return ApiFailure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<HealthReadingEntity>>> getHealthReadings({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final models = await remoteDataSource.getHealthReadings(
        page: page,
        pageSize: pageSize,
      );
      return ApiSuccess(models);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message));
    } catch (e) {
      return ApiFailure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<HealthHistoryEntity>>> getHealthHistory() async {
    try {
      final models = await remoteDataSource.getHealthHistory();
      return ApiSuccess(models);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message));
    } catch (e) {
      return ApiFailure(ServerFailure(message: e.toString()));
    }
  }
}
