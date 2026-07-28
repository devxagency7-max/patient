import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/patient_conditions/data/datasources/patient_condition_remote_datasource.dart';
import 'package:pharmacare/features/patient_conditions/domain/entities/patient_condition_entity.dart';
import 'package:pharmacare/features/patient_conditions/domain/repositories/patient_condition_repository.dart';

class PatientConditionRepositoryImpl implements PatientConditionRepository {
  final PatientConditionRemoteDataSource remoteDataSource;

  PatientConditionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<PatientConditionEntity>> createCondition({
    required String type,
    required String name,
    String? description,
    String? imageUrl,
    String? diagnosedAt,
  }) async {
    try {
      final condition = await remoteDataSource.createCondition(
        type: type,
        name: name,
        description: description,
        imageUrl: imageUrl,
        diagnosedAt: diagnosedAt,
      );
      return ApiSuccess(condition);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<PatientConditionEntity>>> getConditions({
    String? type,
    required int page,
    required int pageSize,
  }) async {
    try {
      final conditions = await remoteDataSource.getConditions(type: type, page: page, pageSize: pageSize);
      return ApiSuccess(conditions);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteCondition(String id) async {
    try {
      await remoteDataSource.deleteCondition(id);
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
