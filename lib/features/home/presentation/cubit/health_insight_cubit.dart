import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/home/domain/repositories/health_insight_repository.dart';
import 'package:pharmacare/features/home/presentation/cubit/health_insight_state.dart';

class HealthInsightCubit extends Cubit<HealthInsightState> {
  final HealthInsightRepository healthInsightRepository;

  HealthInsightCubit({required this.healthInsightRepository}) : super(HealthInsightInitial());

  Future<void> fetchHealthInsight() async {
    emit(HealthInsightLoading());
    final result = await healthInsightRepository.getHealthInsight();

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(HealthInsightLoaded(data));
      case ApiFailure(:final failure):
        emit(HealthInsightError(failure.message));
    }
  }
}
