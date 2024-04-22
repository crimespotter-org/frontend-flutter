import 'dart:typed_data';

class ExploreCardData {
  List<Uint8List> imageUrls;
  List<MediaButton>? buttons;
  String summary;
  String title;
  String id;

  ExploreCardData(
      {required this.imageUrls,
      this.buttons,
      required this.summary,
      required this.title,
      required this.id});
}

class MediaButton {
  String url;
  String type;

  MediaButton(this.type, this.url);

  MediaButton copyWith({String? type, String? url}) {
    return MediaButton(
      type ?? this.type,
      url ?? this.url,
    );
  }
}
