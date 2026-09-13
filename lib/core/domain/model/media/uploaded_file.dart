import '../../../utils/json_parse.dart';

/// `POST /media/upload`.
class UploadedFile {
  const UploadedFile({
    required this.url,
    this.fileName,
    this.fileSizeKb = 0,
    this.mimeType,
  });

  final String url;
  final String? fileName;
  final double fileSizeKb;
  final String? mimeType;

  factory UploadedFile.fromJson(Map<String, dynamic> json) => UploadedFile(
        url: asString(json['url']),
        fileName: asStringOrNull(json['file_name']),
        fileSizeKb: asDouble(json['file_size_kb']),
        mimeType: asStringOrNull(json['mime_type']),
      );

  bool get isImage => (mimeType ?? '').startsWith('image/');
}
