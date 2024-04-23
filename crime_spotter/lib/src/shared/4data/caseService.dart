import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CaseService {
  static Future<List<ExploreCardData>> readData() async {
    var response =
        await SupaBaseConst.supabase.from('cases').select('*,furtherlinks (*)');

    List<ExploreCardData> temp = [];

    for (var item in response) {
      List<Links> links = <Links>[];

      if (item['furtherlinks'] != null) {
        for (var link in item['furtherlinks']) {
          String url = "no url";
          String type = "default";
          if (link['url'] != null) {
            url = link['url'] as String;
          }
          if (link['link_type'] != null) {
            type = link['link_type'] as String;
          }
          links.add(
            Links(type, url, link['id']),
          );
        }
      }

      String summary = "no summary jet";
      if (item['summary'] != null) {
        summary = item['summary'] as String;
      }

      String title = "no title";
      if (item['title'] != null) {
        title = item['title'] as String;
      }

      List<Media> media = [];

      String storageDir = 'case-${item['id']}';
      List<FileObject> files = await SupaBaseConst.supabase.storage
          .from('media')
          .list(path: storageDir);
      for (var x in files) {
        try {
          var signedUrl = await SupaBaseConst.supabase.storage
              .from('media')
              .download('$storageDir/${x.name}');
          media.add(Media(image: signedUrl, name: x.name));
        } catch (ex) {
          continue;
        }
      }
      temp.add(
        ExploreCardData(
          images: media,
          furtherLinks: links.isEmpty ? [] : links,
          summary: summary,
          title: title,
          case_type: item['case_type'],
          id: item['id'],
        ),
      );
    }
    return temp;
  }
}
