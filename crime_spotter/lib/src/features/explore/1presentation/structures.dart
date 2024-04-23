import 'dart:io';
import 'dart:typed_data';

class ExploreCardData {
  List<Media> images;
  List<Links>? furtherLinks;
  String summary;
  String title;
  String id;

  ExploreCardData(
      {required this.images,
      this.furtherLinks,
      required this.summary,
      required this.title,
      required this.id});
}

class Media {
  Uint8List image;
  String name;
  Media({required this.image, required this.name});
}

class MediaToAdd {
  final String name;
  final File file;

  MediaToAdd(this.name, this.file);
}

class Links {
  String url;
  String type;
  String? id;
  bool updated = false;

  Links(this.type, this.url, this.id, {this.updated = false});
  Links.createNew(this.type, this.url) : id = null;

  Links copyWith({String? type, String? url, String? id}) {
    return Links(
      type ?? this.type,
      url ?? this.url,
      id ?? this.id,
      updated: true,
    );
  }
}
