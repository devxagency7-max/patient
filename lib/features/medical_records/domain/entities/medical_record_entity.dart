import 'package:equatable/equatable.dart';

class MedicalRecordEntity extends Equatable {
  final String id;
  final String fileUrl;
  final String type;
  final String? title;
  final DateTime? recordDate;
  final String? notes;
  final DateTime createdAt;

  const MedicalRecordEntity({
    required this.id,
    required this.fileUrl,
    required this.type,
    this.title,
    this.recordDate,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, fileUrl, type, title, recordDate, notes, createdAt];
}
