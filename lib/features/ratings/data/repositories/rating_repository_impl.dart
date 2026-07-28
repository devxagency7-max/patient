import 'package:pharmacare/core/error/exceptions.dart';
import 'package:pharmacare/core/error/failures.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/ratings/data/datasources/rating_remote_datasource.dart';
import 'package:pharmacare/features/ratings/domain/entities/rating_entity.dart';
import 'package:pharmacare/features/ratings/domain/repositories/rating_repository.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingRemoteDataSource remoteDataSource;

  RatingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ApiResult<RatingEntity>> submitRating({
    required String targetType,
    String? pharmacistId,
    String? pharmacyId,
    required int score,
    String? comment,
  }) async {
    try {
      final rating = await remoteDataSource.submitRating(
        targetType: targetType,
        pharmacistId: pharmacistId,
        pharmacyId: pharmacyId,
        score: score,
        comment: comment,
      );
      return ApiSuccess(rating);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<RatingEntity>>> getPharmacistRatings({
    required String pharmacistId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final ratings = await remoteDataSource.getPharmacistRatings(
        pharmacistId: pharmacistId,
        page: page,
        pageSize: pageSize,
      );
      return ApiSuccess(ratings);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<ApiResult<List<RatingEntity>>> getPharmacyRatings({
    required String pharmacyId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final ratings = await remoteDataSource.getPharmacyRatings(
        pharmacyId: pharmacyId,
        page: page,
        pageSize: pageSize,
      );
      return ApiSuccess(ratings);
    } on ServerException catch (e) {
      return ApiFailure(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const ApiFailure(NetworkFailure());
    } catch (e) {
      return ApiFailure(UnexpectedFailure(message: e.toString()));
    }
  }
}
