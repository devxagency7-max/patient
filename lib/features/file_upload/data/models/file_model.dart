import 'package:pharmacare/features/file_upload/domain/entities/file_entity.dart';

class FileModel extends FileEntity {
  const FileModel({
    required super.id,
    super.fileKey = '',
    required super.url,
    required super.previewUrl,
    required super.type,
    required super.status,
    super.ownerId = '',
    super.mimeType,
    super.size,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    final preview = json['previewUrl'] as String? ?? json['url'] as String? ?? '';
    return FileModel(
      id: json['id'] as String? ?? '',
      fileKey: json['fileKey'] as String? ?? '',
      url: preview,
      previewUrl: preview,
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      mimeType: json['mimeType'] as String?,
      size: json['size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileKey': fileKey,
      'url': url,
      'previewUrl': previewUrl,
      'type': type,
      'status': status,
      'ownerId': ownerId,
      if (mimeType != null) 'mimeType': mimeType,
      if (size != null) 'size': size,
    };
  }
}
