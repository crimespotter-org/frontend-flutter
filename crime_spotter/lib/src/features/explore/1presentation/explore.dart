import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'dart:developer' as developer;

import 'package:crime_spotter/main.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  List<ExploreCard> cases = <ExploreCard>[];

  Future<void> readData() async {
    var response = await supabase.from('cases').select('*,furtherlinks (*)');

    List<ExploreCard> temp = <ExploreCard>[];

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
            MediaButton(
              text: url,
              type: type,
            ),
          );
        }
      }

      // developer.log('log me 1', name: 'my.other.category');
      String summary = "no summary jet";
      if (item['summary'] != null) {
        summary = item['summary'] as String;
      }

      List<String> mediaUrl = <String>["assets/placeholder.png"];
      if (item['url'] != null) {
        //mediaUrl = item['url'] as String;
      }

      temp.add(
        ExploreCard(
          imageUrls: mediaUrl,
          buttons: buttons.isEmpty ? null : buttons,
          text: summary,
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
          ? GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0 && currentIndex > 0) {
                  setState(() {
                    currentIndex--;
                  });
                } else if (details.primaryVelocity! < 0 &&
                    currentIndex < cases.length - 1) {
                  setState(() {
                    currentIndex++;
                  });
                }
              },
              child: Card(
                child: Column(
                  children: [
                    if (cases[currentIndex]
                        .imageUrls
                        .first
                        .contains("placeholder"))
                      SizedBox(
                        height: 300,
                        child: Image.asset(
                          'assets/placeholder.jpg',
                          width: 300.0,
                          height: 300.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                    // else
                    //   SizedBox(
                    //     height: 300,
                    //     child: Image.network(cases[currentIndex].imageUrls,
                    //         fit: BoxFit.cover),
                    //   ),
                    if (cases[currentIndex].buttons != null &&
                        cases[currentIndex].buttons!.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: cases[currentIndex].buttons!.map((button) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text(button.type),
                            ),
                          );
                        }).toList(),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(
                            cases[currentIndex].text,
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: Text("No cases found"),
            ),
    );
  }
}

class ExploreCard {
  final List<String> imageUrls;
  final List<MediaButton>? buttons;
  final String text;

  ExploreCard({required this.imageUrls, this.buttons, required this.text});
}

class MediaButton {
  final String text;
  final String type;

  MediaButton({required this.type, required this.text});
}
