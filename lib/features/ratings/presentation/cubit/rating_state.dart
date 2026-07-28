import 'package:equatable/equatable.dart';
import 'package:pharmacare/features/ratings/domain/entities/rating_entity.dart';

abstract class RatingState extends Equatable {
  const RatingState();

  @override
  List<Object?> get props => [];
}

class RatingInitial extends RatingState {}

class RatingSubmitting extends RatingState {}

class RatingSubmitSuccess extends RatingState {}

class RatingError extends RatingState {
  final String message;

  const RatingError(this.message);

  @override
  List<Object?> get props => [message];
}

class RatingListLoading extends RatingState {}

class RatingListLoaded extends RatingState {
  final List<RatingEntity> ratings;

  const RatingListLoaded(this.ratings);

  double get averageScore => ratings.isEmpty
      ? 0
      : ratings.map((r) => r.score).reduce((a, b) => a + b) / ratings.length;

  @override
  List<Object?> get props => [ratings];
}

class RatingListError extends RatingState {
  final String message;

  const RatingListError(this.message);

  @override
  List<Object?> get props => [message];
}
