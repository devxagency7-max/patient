import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/ratings/domain/entities/rating_entity.dart';

abstract class RatingRepository {
  Future<ApiResult<RatingEntity>> submitRating({
    required String targetType,
    String? pharmacistId,
    String? pharmacyId,
    required int score,
    String? comment,
  });

  Future<ApiResult<List<RatingEntity>>> getPharmacistRatings({
    required String pharmacistId,
    required int page,
    required int pageSize,
  });

  Future<ApiResult<List<RatingEntity>>> getPharmacyRatings({
    required String pharmacyId,
    required int page,
    required int pageSize,
  });
}
