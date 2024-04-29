import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/caseService.dart';
import 'package:flutter/material.dart';

class SingleCase extends StatefulWidget {
  const SingleCase({super.key});

  @override
  State<SingleCase> createState() => _SingleCaseState();
}

class _SingleCaseState extends State<SingleCase> {
  late Future<CaseDetails> _caseFuture;
  String? caseID;

  Future<void> loadData() async {
    caseID = ModalRoute.of(context)?.settings.arguments as String?;
    _caseFuture = CaseService.getCaseDetailedById(caseID!);
  }

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CaseDetails>(
      future: _caseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Display a loading indicator while waiting for the data
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // Display an error message if something went wrong
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          // Data has been loaded successfully
          final loadedCase = snapshot.data!;
          return SingleCaseBodyWidget(shownCase: loadedCase);
        }
      },
    );
  }
}

class SingleCaseBodyWidget extends StatelessWidget {
  final CaseDetails shownCase;

  const SingleCaseBodyWidget({required this.shownCase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shownCase.title),
      ),
      body: Card(
        child: Column(
          children: [
            if (shownCase.images.isEmpty)
              SizedBox(
                  height: 300,
                  child: Image.asset(
                    "assets/placeholder.jpg",
                    fit: BoxFit.fitHeight,
                  ))
            else
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.5,
                child: PageView.builder(
                  itemCount: shownCase.images.length,
                  itemBuilder: (context, index) {
                    return Image.memory(
                      shownCase.images[index].image,
                      fit: BoxFit.fitHeight,
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            if (shownCase!.furtherLinks.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: shownCase.furtherLinks.map((button) {
                  IconData iconData;
                  switch (button.type) {
                    case "book":
                      iconData = Icons.book;
                      break;
                    case "podcast":
                      iconData = Icons.headphones;
                      break;
                    case "newspaper":
                      iconData = Icons.newspaper;
                      break;
                    default:
                      iconData = Icons.error; // or any other default icon
                  }

                  return RawMaterialButton(
                    onPressed: () {},
                    elevation: 2.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(10.0),
                    shape: const CircleBorder(),
                    child: Icon(
                      iconData,
                      size: 25.0,
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 10),
            DefaultTextStyle.merge(
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              child: const Center(
                child: Text('Zusammenfassung:'),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    shownCase.summary,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
