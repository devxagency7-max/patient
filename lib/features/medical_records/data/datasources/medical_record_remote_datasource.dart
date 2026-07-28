import 'package:pharmacare/features/medical_records/data/models/medical_record_model.dart';

abstract class MedicalRecordRemoteDataSource {
  Future<MedicalRecordModel> createMedicalRecord({
    required String uploadedFileId,
    required String type,
    String? title,
    String? recordedAt,
  });

  Future<List<MedicalRecordModel>> getMedicalRecords({
    String? type,
    required int page,
    required int pageSize,
  });

  Future<void> deleteMedicalRecord(String id);
}
