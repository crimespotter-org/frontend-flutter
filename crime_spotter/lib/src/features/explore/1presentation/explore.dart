import 'package:crime_spotter/src/features/explore/1presentation/case_tile_short.dart';
import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/caseService.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:flutter/material.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  List<CaseDetails> cases = [];

  Future<void> loadData() async {
    List<CaseDetails> loadedCases =
        await CaseService.getCasesIncludingFirstImage();
    if (mounted) {
      setState(() {
        cases = loadedCases;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fälle erkunden'),
      ),
      body: Stack(
        children: [
          cases.isNotEmpty
              ? ListView.builder(
                  itemCount: cases.length,
                  itemBuilder: (context, index) {
                    return CaseTileShort(
                      shownCase: cases[index],
                    );
                  },
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
                    ],
                  ),
                ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: FloatingActionButton(
              backgroundColor: TColor.buttonColor,
              onPressed: () async {
                setState(
                  () {
                    Navigator.pushNamed(context, UIData.edit_case,
                        arguments: "-1");
                  },
                );
              },
              tooltip: "Neuen Fall hinzufügen",
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
