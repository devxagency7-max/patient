import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/home/data/datasources/health_insight_remote_datasource.dart';
import 'package:pharmacare/features/home/domain/entities/health_insight_entity.dart';
import 'package:pharmacare/features/home/domain/repositories/health_insight_repository.dart';

class HealthInsightRepositoryImpl implements HealthInsightRepository {
  final HealthInsightRemoteDataSource remoteDataSource;

  HealthInsightRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<HealthInsightEntity>> getHealthInsight() async {
    try {
      final insight = await remoteDataSource.getHealthInsight();
      return ApiSuccess(insight);
    } on ServerException catch (e) {
      if (e.statusCode == 403) {
        return ApiFailure(ForbiddenFailure(message: e.message));
      }
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
