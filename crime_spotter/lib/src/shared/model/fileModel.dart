import 'dart:typed_data';

class FileModel {
  String extension;
  Uint8List imageInBytes;
  String userId;

  FileModel({
    required this.userId,
    required this.imageInBytes,
    required this.extension,
  });
}
