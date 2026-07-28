import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/prescription/domain/entities/prescription_entity.dart';

abstract class PrescriptionRepository {
  Future<ApiResult<PrescriptionEntity>> createPrescription({
    String? doctorName,
    String? clinicName,
    String? issueDate,
    String? expiryDate,
    List<String> imageUrls,
  });

  Future<ApiResult<List<PrescriptionEntity>>> getMyPrescriptions({
    required int page,
    required int pageSize,
  });

  Future<ApiResult<PrescriptionEntity>> getPrescriptionById(String id);
}
