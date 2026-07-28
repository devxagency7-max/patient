class FileEntity {
  final String id;
  final String fileKey;
  final String url;
  final String previewUrl;
  final String type;
  final String status;
  final String ownerId;
  final String? mimeType;
  final int? size;

  const FileEntity({
    required this.id,
    this.fileKey = '',
    required this.url,
    required this.previewUrl,
    required this.type,
    required this.status,
    this.ownerId = '',
    this.mimeType,
    this.size,
  });
}

