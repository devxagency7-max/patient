import 'package:pharmacare/features/ratings/domain/entities/rating_entity.dart';

class RatingModel extends RatingEntity {
  const RatingModel({
    required super.id,
    required super.reviewerId,
    required super.reviewerName,
    required super.targetType,
    super.pharmacistId,
    super.pharmacyId,
    required super.score,
    super.comment,
    required super.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String? ?? '',
      reviewerId: json['reviewerId'] as String? ?? '',
      reviewerName: json['reviewerName'] as String? ?? '',
      targetType: json['targetType'] as String? ?? '',
      pharmacistId: json['pharmacistId'] as String?,
      pharmacyId: json['pharmacyId'] as String?,
      score: json['score'] as int? ?? 0,
      comment: json['comment'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
