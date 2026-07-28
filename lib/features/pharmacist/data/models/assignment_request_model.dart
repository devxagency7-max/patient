import 'package:pharmacare/features/pharmacist/domain/entities/assignment_request_entity.dart';

class AssignmentRequestModel extends AssignmentRequestEntity {
  const AssignmentRequestModel({
    required super.assignmentId,
    required super.pharmacistId,
    required super.pharmacistName,
    required super.status,
    super.patientNote,
    super.rejectionReason,
    required super.requestedAt,
    super.conversationId,
  });

  factory AssignmentRequestModel.fromJson(Map<String, dynamic> json) {
    return AssignmentRequestModel(
      assignmentId: json['assignmentId'] as String? ?? '',
      pharmacistId: json['pharmacistId'] as String? ?? '',
      pharmacistName: json['pharmacistName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      patientNote: json['patientNote'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      requestedAt: DateTime.tryParse(json['requestedAt'] as String? ?? '') ?? DateTime.now(),
      conversationId: json['conversationId'] as String?,
    );
  }
}
