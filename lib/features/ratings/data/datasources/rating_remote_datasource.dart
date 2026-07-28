import 'package:pharmacare/features/ratings/data/models/rating_model.dart';

abstract class RatingRemoteDataSource {
  Future<RatingModel> submitRating({
    required String targetType,
    String? pharmacistId,
    String? pharmacyId,
    required int score,
    String? comment,
  });

  Future<List<RatingModel>> getPharmacistRatings({
    required String pharmacistId,
    required int page,
    required int pageSize,
  });

  Future<List<RatingModel>> getPharmacyRatings({
    required String pharmacyId,
    required int page,
    required int pageSize,
  });
}
