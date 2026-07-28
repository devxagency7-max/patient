import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/patient_conditions/domain/entities/patient_condition_entity.dart';

abstract class PatientConditionRepository {
  Future<ApiResult<PatientConditionEntity>> createCondition({
    required String type,
    required String name,
    String? diagnosedAt,
  });

  Future<ApiResult<List<PatientConditionEntity>>> getConditions({
    String? type,
    required int page,
    required int pageSize,
  });

  Future<ApiResult<void>> deleteCondition(String id);
}
