import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/ratings/domain/repositories/rating_repository.dart';
import 'package:pharmacare/features/ratings/presentation/cubit/rating_state.dart';

class RatingCubit extends Cubit<RatingState> {
  final RatingRepository ratingRepository;

  RatingCubit({required this.ratingRepository}) : super(RatingInitial());

  Future<void> submitRating({
    required String targetType,
    String? pharmacistId,
    String? pharmacyId,
    required int score,
    String? comment,
  }) async {
    emit(RatingSubmitting());

    final result = await ratingRepository.submitRating(
      targetType: targetType,
      pharmacistId: pharmacistId,
      pharmacyId: pharmacyId,
      score: score,
      comment: comment,
    );

    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        emit(RatingSubmitSuccess());
      case ApiFailure(:final failure):
        emit(RatingError(failure.message));
    }
  }

  Future<void> fetchPharmacistRatings({
    required String pharmacistId,
    int page = 1,
    int pageSize = 20,
  }) async {
    emit(RatingListLoading());

    final result = await ratingRepository.getPharmacistRatings(
      pharmacistId: pharmacistId,
      page: page,
      pageSize: pageSize,
    );

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(RatingListLoaded(data));
      case ApiFailure(:final failure):
        emit(RatingListError(failure.message));
    }
  }

  Future<void> fetchPharmacyRatings({
    required String pharmacyId,
    int page = 1,
    int pageSize = 20,
  }) async {
    emit(RatingListLoading());

    final result = await ratingRepository.getPharmacyRatings(
      pharmacyId: pharmacyId,
      page: page,
      pageSize: pageSize,
    );

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(RatingListLoaded(data));
      case ApiFailure(:final failure):
        emit(RatingListError(failure.message));
    }
  }
}
