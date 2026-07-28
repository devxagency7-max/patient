import 'package:equatable/equatable.dart';

class RatingEntity extends Equatable {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String targetType;
  final String? pharmacistId;
  final String? pharmacyId;
  final int score;
  final String? comment;
  final DateTime createdAt;

  const RatingEntity({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.targetType,
    this.pharmacistId,
    this.pharmacyId,
    required this.score,
    this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        reviewerId,
        reviewerName,
        targetType,
        pharmacistId,
        pharmacyId,
        score,
        comment,
        createdAt,
      ];
}
