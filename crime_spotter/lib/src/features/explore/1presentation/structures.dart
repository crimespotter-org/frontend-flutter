import 'dart:io';
import 'dart:typed_data';

class ExploreCardData {
  List<Media> images;
  List<Links>? furtherLinks;
  String summary;
  String title;
  String case_type;
  String? id;
  bool isNew = false;

  ExploreCardData(
      {required this.images,
      this.furtherLinks,
      required this.summary,
      required this.title,
      required this.case_type,
      required this.id});
  ExploreCardData.createNew()
      : images = [],
        furtherLinks = [],
        summary = "",
        title = "",
        case_type = "murder",
        id = null,
        isNew = true;
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
  bool isNew = false;
  bool delete = false;

  Links(this.type, this.url, this.id, {this.updated = false});
  Links.createNew()
      : type = 'newspaper',
        url = '',
        isNew = true,
        id = null;

  Links copyWith({String? type, String? url, String? id}) {
    return Links(
      type ?? this.type,
      url ?? this.url,
      id ?? this.id,
      updated: true,
    );
  }
}
