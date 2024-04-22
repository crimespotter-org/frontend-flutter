import 'package:supabase_flutter/supabase_flutter.dart';

class ExploreCardData {
  List<String> imageUrls;
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
