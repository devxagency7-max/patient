import 'package:equatable/equatable.dart';

class PrescriptionEntity extends Equatable {
  final String id;
  final String status;
  final String? doctorName;
  final String? clinicName;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final List<String> imageUrls;
  final DateTime createdAt;

  const PrescriptionEntity({
    required this.id,
    required this.status,
    this.doctorName,
    this.clinicName,
    this.issueDate,
    this.expiryDate,
    this.imageUrls = const [],
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        doctorName,
        clinicName,
        issueDate,
        expiryDate,
        imageUrls,
        createdAt,
      ];
}
