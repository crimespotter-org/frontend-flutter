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
  String text;
  String type;

  MediaButton({required this.type, required this.text});
}
