import 'package:equatable/equatable.dart';

class AssignmentRequestEntity extends Equatable {
  final String assignmentId;
  final String pharmacistId;
  final String pharmacistName;
  final String status;
  final String? patientNote;
  final String? rejectionReason;
  final DateTime requestedAt;
  // Only ever non-null when status == "Active", and even then may still be
  // null if neither side has sent a first message yet — in that case use
  // POST /chat/conversations (idempotent) to create/fetch it. Never derive
  // this from GET /chat/conversations: that endpoint mixes the pharmacist
  // conversation together with the AI thread and any order-related ones
  // with no type distinction, so "most recent" is not reliably this one.
  final String? conversationId;

  const AssignmentRequestEntity({
    required this.assignmentId,
    required this.pharmacistId,
    required this.pharmacistName,
    required this.status,
    this.patientNote,
    this.rejectionReason,
    required this.requestedAt,
    this.conversationId,
  });

  @override
  List<Object?> get props => [
    assignmentId,
    pharmacistId,
    pharmacistName,
    status,
    patientNote,
    rejectionReason,
    requestedAt,
    conversationId,
  ];
}
