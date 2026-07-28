import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/medical_records/domain/entities/medical_record_entity.dart';

abstract class MedicalRecordRepository {
  Future<ApiResult<MedicalRecordEntity>> createMedicalRecord({
    required String uploadedFileId,
    required String type,
    String? title,
    String? recordedAt,
  });

  Future<ApiResult<List<MedicalRecordEntity>>> getMedicalRecords({
    String? type,
    required int page,
    required int pageSize,
  });

  Future<ApiResult<void>> deleteMedicalRecord(String id);
}
