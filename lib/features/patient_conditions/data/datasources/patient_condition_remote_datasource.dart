import 'package:pharmacare/features/patient_conditions/data/models/patient_condition_model.dart';

abstract class PatientConditionRemoteDataSource {
  Future<PatientConditionModel> createCondition({
    required String type,
    required String name,
    String? diagnosedAt,
  });

  Future<List<PatientConditionModel>> getConditions({
    String? type,
    required int page,
    required int pageSize,
  });

  Future<void> deleteCondition(String id);
}
