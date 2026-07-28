import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/pharmacist/domain/entities/assignment_request_entity.dart';
import 'package:pharmacare/features/pharmacist/domain/entities/pharmacist_entity.dart';

abstract class PharmacistRepository {
  Future<ApiResult<List<PharmacistEntity>>> getPharmacists();
  Future<ApiResult<void>> requestPharmacist({required String pharmacistId});
  Future<ApiResult<List<AssignmentRequestEntity>>> getMyRequests();
  Future<ApiResult<void>> cancelRequest(String requestId);
  Future<ApiResult<void>> terminateRelationship(String requestId);
}
