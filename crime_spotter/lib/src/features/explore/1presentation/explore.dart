import 'dart:typed_data';

import 'package:crime_spotter/src/features/explore/1presentation/case_tile_short.dart';
import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  List<ExploreCardData> cases = [];

  Future<void> readData() async {
    var response =
        await SupaBaseConst.supabase.from('cases').select('*,furtherlinks (*)');

    List<ExploreCardData> temp = [];

    for (var item in response) {
      List<Links> buttons = <Links>[];

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
          buttons.add(
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
          furtherLinks: buttons.isEmpty ? null : buttons,
          summary: summary,
          title: title,
          id: item['id'],
        ),
      );
    }

    setState(() {
      cases.addAll(temp);
    });
  }

  @override
  void initState() {
    super.initState();
    readData();
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: cases.isNotEmpty
          ? Expanded(
              child: ListView.builder(
                itemCount: cases.length,
                itemBuilder: (context, index) {
                  return CaseTileShort(
                    shownCase: cases[index],
                  );
                },
              ),
            )
          : const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Fallakten werden geladen"),
                    SizedBox(
                      height: 20,
                    ),
                    CircularProgressIndicator(),
                  ]),
            ),
    );
  }
}
