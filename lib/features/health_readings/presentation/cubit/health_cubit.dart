import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/health_readings/domain/usecases/health_usecases.dart';
import 'package:pharmacare/features/health_readings/presentation/cubit/health_state.dart';

class HealthCubit extends Cubit<HealthState> {
  final AddHealthReadingUseCase addReadingUseCase;
  final GetHealthReadingsUseCase getReadingsUseCase;
  final GetHealthHistoryUseCase getHistoryUseCase;

  HealthCubit({
    required this.addReadingUseCase,
    required this.getReadingsUseCase,
    required this.getHistoryUseCase,
  }) : super(const HealthInitial());

  Future<void> addReading({
    required String type,
    required double value,
    required DateTime recordedAt,
  }) async {
    emit(const HealthLoading());

    final result = await addReadingUseCase(
      type: type,
      value: value,
      recordedAt: recordedAt,
    );

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(HealthSuccess(newReading: data));
      case ApiFailure(:final failure):
        emit(HealthError(failure.message));
    }
  }

  Future<void> fetchHistory() async {
    emit(const HealthLoading());

    final result = await getHistoryUseCase();

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(HealthSuccess(history: data));
      case ApiFailure(:final failure):
        emit(HealthError(failure.message));
    }
  }

  Future<void> fetchReadings({int page = 1}) async {
    emit(const HealthLoading());

    final result = await getReadingsUseCase(page: page);

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(HealthSuccess(readings: data));
      case ApiFailure(:final failure):
        emit(HealthError(failure.message));
    }
  }
}
