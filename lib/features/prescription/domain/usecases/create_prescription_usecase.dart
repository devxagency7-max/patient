import 'package:pharmacare/core/network/api_result.dart';
import 'package:pharmacare/features/prescription/domain/entities/prescription_entity.dart';
import 'package:pharmacare/features/prescription/domain/repositories/prescription_repository.dart';

class CreatePrescriptionUseCase {
  final PrescriptionRepository repository;

  CreatePrescriptionUseCase(this.repository);

  Future<ApiResult<PrescriptionEntity>> call({
    String? doctorName,
    String? clinicName,
    String? issueDate,
    String? expiryDate,
    List<String> imageUrls = const [],
  }) {
    return repository.createPrescription(
      doctorName: doctorName,
      clinicName: clinicName,
      issueDate: issueDate,
      expiryDate: expiryDate,
      imageUrls: imageUrls,
    );
  }
}
