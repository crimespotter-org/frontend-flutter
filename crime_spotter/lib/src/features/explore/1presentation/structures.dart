class ExploreCard {
  List<String> imageUrls;
  List<MediaButton>? buttons;
  String summary;
  String title;

  ExploreCard(
      {required this.imageUrls,
      this.buttons,
      required this.summary,
      required this.title});
}

class MediaButton {
  String text;
  String type;

  MediaButton({required this.type, required this.text});
}
