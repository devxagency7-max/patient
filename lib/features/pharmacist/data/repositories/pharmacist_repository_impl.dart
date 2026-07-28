import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/pharmacist/data/datasources/pharmacist_remote_datasource.dart';
import 'package:pharmacare/features/pharmacist/domain/entities/assignment_request_entity.dart';
import 'package:pharmacare/features/pharmacist/domain/entities/pharmacist_entity.dart';
import 'package:pharmacare/features/pharmacist/domain/repositories/pharmacist_repository.dart';

class PharmacistRepositoryImpl implements PharmacistRepository {
  final PharmacistRemoteDataSource remoteDataSource;

  PharmacistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<List<PharmacistEntity>>> getPharmacists() async {
    try {
      final pharmacists = await remoteDataSource.getPharmacists();
      return ApiSuccess(pharmacists);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> requestPharmacist({required String pharmacistId}) async {
    try {
      await remoteDataSource.requestPharmacist(pharmacistId: pharmacistId);
      return const ApiSuccess(null);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<AssignmentRequestEntity>>> getMyRequests() async {
    try {
      final requests = await remoteDataSource.getMyRequests();
      return ApiSuccess(requests);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> cancelRequest(String requestId) async {
    try {
      await remoteDataSource.cancelRequest(requestId);
      return const ApiSuccess(null);
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

  @override
  Future<ApiResult<void>> terminateRelationship(String requestId) async {
    try {
      await remoteDataSource.terminateRelationship(requestId);
      return const ApiSuccess(null);
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
