import 'package:crime_spotter/src/features/explore/1presentation/case_tile_short.dart';
import 'package:crime_spotter/src/features/explore/1presentation/exploreArgs.dart';
import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/features/map/views/map_option.dart';
import 'package:crime_spotter/src/shared/4data/card_provider.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/case_service.dart';
import 'package:crime_spotter/src/shared/4data/userdetails_provider.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:flutter/foundation.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var userProvider = Provider.of<UserDetailsProvider>(context);
    var role = userProvider.userRole;

    var provider = Provider.of<CaseProvider>(context);
    List<CaseDetails> loadedCases = provider.casesDetailed;

    if (role == UserRole.admin || role == UserRole.crimefluencer) {
      setState(() {
        cases = loadedCases;
        canEdit = true;
      });
    } else {
      setState(() {
        cases = loadedCases;
        canEdit = false;
      });
    }

    super.didChangeDependencies();
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)?.settings.arguments as ExploreArgs;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Fälle erkunden'),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return SingleChildScrollView(
                      child: TMapOption(
                        controller: args.mapController,
                        markers: args.markers,
                        selectedFilter: args.selectedFilter,
                      ),
                    );
                  },
                );
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
                          shownCase: cases[index], canEdit: canEdit);
                    },
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
                    setState(
                      () {
                        Navigator.pushNamed(context, UIData.editCase,
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
      ),
    );
  }
}
