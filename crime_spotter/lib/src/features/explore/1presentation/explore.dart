import 'dart:io';
import 'dart:typed_data';

import 'package:crime_spotter/src/features/explore/1presentation/case_tile_short.dart';
import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:flutter/material.dart';
import 'package:format/format.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  List<ExploreCardData> cases = <ExploreCardData>[];

  Future<void> readData() async {
    var response =
        await SupaBaseConst.supabase.from('cases').select('*,furtherlinks (*)');

    List<ExploreCardData> temp = <ExploreCardData>[];

    for (var item in response) {
      List<MediaButton> buttons = <MediaButton>[];

      if (item['furtherlinks'] != null) {
        for (var link in item['furtherlinks']) {
          String url = "no url";
          String type = "default";
          if (link['url'] != null) {
            url = link['url'] as String;
          }
          if (link['type'] != null) {
            type = link['type'] as String;
          }
          buttons.add(
            MediaButton(type, url),
          );
        }
      }

      // developer.log('log me 1', name: 'my.other.category');
      String summary = "no summary jet";
      if (item['summary'] != null) {
        summary = item['summary'] as String;
      }

      String title = "no title";
      if (item['title'] != null) {
        title = item['title'] as String;
      }

      List<String> mediaUrl = [];
      try {
        String storageDir = 'case-${item['id']}';
        print(storageDir);
        List<FileObject> files = await SupaBaseConst.supabase.storage
            .from('media')
            .list(path: storageDir);
        for (var x in files) {
          final String signedUrl = await SupaBaseConst.supabase.storage
              .from('media')
              .createSignedUrl('case-${item['id']}/${x.name}', 300);
          mediaUrl.add(signedUrl);
        }
        if (mediaUrl.length == 0) {
          mediaUrl.add("assets/placeholder.jpg");
        }
      } catch (e) {
        mediaUrl.add("assets/placeholder.jpg");
      }

      temp.add(
        ExploreCardData(
          imageUrls: mediaUrl,
          buttons: buttons.isEmpty ? null : buttons,
          summary: summary,
          title: title,
          id: item['id'],
        ),
      );
      // developer.log(temp.length.toString(), name: 'my.other.category');
    }

    setState(() {
      cases = temp;
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
              child: Text("No cases found"),
            ),
    );
  }
}
