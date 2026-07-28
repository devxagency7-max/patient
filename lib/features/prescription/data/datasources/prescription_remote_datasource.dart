import 'package:pharmacare/features/prescription/data/models/prescription_model.dart';

abstract class PrescriptionRemoteDataSource {
  Future<PrescriptionModel> createPrescription({
    String? doctorName,
    String? clinicName,
    String? issueDate,
    String? expiryDate,
    List<String> imageUrls,
  });

  Future<List<PrescriptionModel>> getMyPrescriptions({
    required int page,
    required int pageSize,
  });

  Future<PrescriptionModel> getPrescriptionById(String id);
}
