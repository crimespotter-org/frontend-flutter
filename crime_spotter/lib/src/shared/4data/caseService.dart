import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CaseService {
  static Future<List<CaseDetails>> getAllCases() async {
    // var response = await SupaBaseConst.supabase.from('cases').select(
    //     'id, title, summary, ST_Y(location::geometry) as lat, ST_X(location::geometry) as long, created_by, created_at, place_name, zip_code, case_type, crime_date_time, status');

    var response = await SupaBaseConst.supabase.rpc('get_all_cases_flutter');

    List<CaseDetails> temp = [];

    for (var item in response) {
      temp.add(
        CaseDetails.fromJson(item),
      );
    }
    return temp;
  }

  static Future<List<CaseDetails>> getCasesIncludingFirstImage() async {
    var response = await SupaBaseConst.supabase.rpc('get_all_cases_flutter');

    List<CaseDetails> temp = [];

    for (var item in response) {
      CaseDetails newItem = CaseDetails.fromJson(item);

      String storageDir = 'case-${newItem.id}';
      List<FileObject> files = await SupaBaseConst.supabase.storage
          .from('media')
          .list(path: storageDir);
      try {
        var signedUrl = await SupaBaseConst.supabase.storage
            .from('media')
            .download('$storageDir/${files.first.name}');
        newItem.images.add(Media(image: signedUrl, name: files.first.name));
      } catch (ex) {
        continue;
      } finally {
        temp.add(newItem);
      }
    }

    return temp;
  }

  static Future<CaseDetails> getCaseDetailedById(String id) async {
    var response = await SupaBaseConst.supabase
        .rpc('get_case_detailed_flutter', params: {'case_id': id});
    CaseDetails item = CaseDetails.fromJson(response.first);

    //links
    for (var link in response) {
      item.furtherLinks.add(
        Links.fromJson(link),
      );
    }

    //images
    String storageDir = 'case-${item.id}';
    List<FileObject> files = await SupaBaseConst.supabase.storage
        .from('media')
        .list(path: storageDir);
    for (var x in files) {
      try {
        var signedUrl = await SupaBaseConst.supabase.storage
            .from('media')
            .download('$storageDir/${x.name}');
        item.images.add(Media(image: signedUrl, name: x.name));
      } catch (ex) {
        continue;
      }
    }

    //votes
    var votesResult = await SupaBaseConst.supabase
        .rpc('get_case_votes_by_id', params: {'p_case_id': item.id});
    var votes = votesResult.isNotEmpty ? votesResult.first : null;

    if (votes != null) {
      item.upvotes = votes["upvotes"];
      item.downvotes = votes["downvotes"];
    }
    //comments
    var commentsResponse = await SupaBaseConst.supabase
        .rpc('get_comments', params: {'p_case_id': item.id});
    var comments = commentsResponse.isNotEmpty ? commentsResponse : null;
    if (comments != null) {
      for (var r in commentsResponse) {
        item.comments.add(
          Comment.fromJson(r),
        );
      }
    }

    return item;
  }

  static Future<List<Comment>> loadCommentsOfCase(String caseID) async {
    var response = await SupaBaseConst.supabase
        .rpc('get_comments', params: {'p_case_id': caseID});

    List<Comment> temp = [];

    for (var item in response) {
      temp.add(
        Comment.fromJson(item),
      );
    }
    return temp;
  }

  // static Future<List<CaseDetails>> readData() async {
  //   var response =
  //       await SupaBaseConst.supabase.from('cases').select('*,furtherlinks (*)');

  //   List<CaseDetails> temp = [];

  //   for (var item in response) {
  //     List<Links> links = <Links>[];

  //     if (item['furtherlinks'] != null) {
  //       for (var link in item['furtherlinks']) {
  //         String url = "no url";
  //         String type = "default";
  //         if (link['url'] != null) {
  //           url = link['url'] as String;
  //         }
  //         if (link['link_type'] != null) {
  //           type = link['link_type'] as String;
  //         }
  //         links.add(
  //           Links(type, url, link['id']),
  //         );
  //       }
  //     }

  //     String summary = "no summary jet";
  //     if (item['summary'] != null) {
  //       summary = item['summary'] as String;
  //     }

  //     String title = "no title";
  //     if (item['title'] != null) {
  //       title = item['title'] as String;
  //     }

  //     List<Media> media = [];

  //     String storageDir = 'case-${item['id']}';
  //     List<FileObject> files = await SupaBaseConst.supabase.storage
  //         .from('media')
  //         .list(path: storageDir);
  //     for (var x in files) {
  //       try {
  //         var signedUrl = await SupaBaseConst.supabase.storage
  //             .from('media')
  //             .download('$storageDir/${x.name}');
  //         media.add(Media(image: signedUrl, name: x.name));
  //       } catch (ex) {
  //         continue;
  //       }
  //     }
  //     temp.add(
  //       CaseDetails.fromJson(item),
  //     );
  //   }
  //   return temp;
  // }
}
