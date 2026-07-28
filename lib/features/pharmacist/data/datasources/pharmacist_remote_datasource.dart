import 'package:pharmacare/features/pharmacist/data/models/assignment_request_model.dart';
import 'package:pharmacare/features/pharmacist/data/models/pharmacist_model.dart';

abstract class PharmacistRemoteDataSource {
  Future<List<PharmacistModel>> getPharmacists();
  Future<void> requestPharmacist({required String pharmacistId});
  Future<List<AssignmentRequestModel>> getMyRequests();
  Future<void> cancelRequest(String requestId);
  Future<void> terminateRelationship(String requestId);
}
