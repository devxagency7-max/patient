import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/patient_conditions/domain/repositories/patient_condition_repository.dart';
import 'package:pharmacare/features/patient_conditions/presentation/cubit/patient_condition_state.dart';

class PatientConditionCubit extends Cubit<PatientConditionState> {
  final PatientConditionRepository conditionRepository;

  PatientConditionCubit({required this.conditionRepository}) : super(PatientConditionInitial());

  Future<void> fetchConditions({String? type}) async {
    emit(PatientConditionLoading());

    final result = await conditionRepository.getConditions(type: type, page: 1, pageSize: 50);

    if (isClosed) return;
    switch (result) {
      case ApiSuccess(:final data):
        emit(PatientConditionLoaded(data));
      case ApiFailure(:final failure):
        emit(PatientConditionError(failure.message));
    }
  }

  Future<void> addCondition({
    required String type,
    required String name,
    String? description,
    String? imageUrl,
    String? diagnosedAt,
  }) async {
    final result = await conditionRepository.createCondition(
      type: type,
      name: name,
      description: description,
      imageUrl: imageUrl,
      diagnosedAt: diagnosedAt,
    );

    if (isClosed) return;
    switch (result) {
      case ApiSuccess():
        fetchConditions();
      case ApiFailure(:final failure):
        emit(PatientConditionError(failure.message));
    }
  }

  Future<void> deleteCondition(String id) async {
    final result = await conditionRepository.deleteCondition(id);
    if (isClosed) return;
    if (result is ApiSuccess) {
      fetchConditions();
    }
  }
}
