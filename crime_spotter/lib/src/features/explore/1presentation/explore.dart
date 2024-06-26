import 'dart:async';

import 'package:crime_spotter/src/features/explore/1presentation/case_tile_short.dart';
import 'package:crime_spotter/src/features/explore/1presentation/explore_filter.dart';
import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/card_provider.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/userdetails_provider.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  List<CaseDetails> cases = [];
  bool canEdit = false;
  bool filtering = false;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    var userProvider = Provider.of<UserDetailsProvider>(context);
    var role = userProvider.userRole;

    var provider = Provider.of<CaseProvider>(context, listen: false);

    if (role == UserRole.admin || role == UserRole.crimefluencer) {
      setState(() {
        cases = provider.filteredCasesExploreView;
        canEdit = true;
      });
    } else {
      setState(() {
        cases = provider.filteredCasesExploreView;
        canEdit = false;
      });
    }

    super.didChangeDependencies();
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Fälle erkunden'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const ExploreFilter();
                  },
                ).then((value) => setState(
                      () {
                        var provider =
                            Provider.of<CaseProvider>(context, listen: false);
                        filtering = true;
                        cases = provider.filteredCasesExploreView;
                      },
                    ));
              },
            ),
            if (filtering)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  var provider =
                      Provider.of<CaseProvider>(context, listen: false);
                  var userProvider =
                      Provider.of<UserDetailsProvider>(context, listen: false);
                  provider.filterForExplore(userProvider: userProvider);

                  setState(() {
                    filtering = false;
                  });
                },
              ),
          ],
        ),
        foregroundColor: Colors.white,
        backgroundColor: TColor.backgroundColor,
        surfaceTintColor: TColor.backgroundColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Backgroung.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            cases.isNotEmpty
                ? ListView.builder(
                    itemCount: cases.length,
                    itemBuilder: (context, index) {
                      return CaseTileShort(
                        shownCase: cases[index],
                        canEdit: canEdit,
                        callback: _updateState,
                      );
                    },
                  )
                : filtering
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Keine Fälle gefunden",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Fallakten werden geladen",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            CircularProgressIndicator(
                              color: TColor.buttonColor,
                            ),
                          ],
                        ),
                      ),
            if (canEdit)
              Positioned(
                bottom: 16.0,
                left: 16.0,
                child: FloatingActionButton(
                  heroTag: "addCase",
                  backgroundColor: TColor.buttonColor,
                  onPressed: () async {
                    await Navigator.pushNamed(context, UIData.editCase,
                        arguments: "-1");
                    if (mounted) {
                      var provider =
                          // ignore: use_build_context_synchronously
                          Provider.of<CaseProvider>(context, listen: false);
                      var temp = provider.filteredCasesExploreView;
                      setState(
                        () {
                          cases = temp;
                        },
                      );
                    }
                  },
                  tooltip: "Neuen Fall hinzufügen",
                  child: const Icon(Icons.add),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _updateState() {
    var provider = Provider.of<CaseProvider>(context, listen: false);
    var temp = provider.filteredCasesExploreView;
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        cases = temp;
      });
    });
  }
}
