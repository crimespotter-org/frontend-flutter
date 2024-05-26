import 'package:crime_spotter/src/features/explore/1presentation/case_tile_short.dart';
import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
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

  @override
  void didChangeDependencies() {
    var userProvider = Provider.of<UserDetailsProvider>(context);
    var role = userProvider.userRole;
    if (role == UserRole.admin || role == UserRole.crimefluencer) {
      setState(() {
        canEdit = true;
      });
    }

    super.didChangeDependencies();
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fälle erkunden'),
        foregroundColor: Colors.white,
        backgroundColor: TColor.backgroundColor,
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
