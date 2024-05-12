import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:crime_spotter/src/shared/4data/caseService.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:crime_spotter/src/shared/4data/userdetailsProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleCase extends StatefulWidget {
  const SingleCase({super.key});

  @override
  State<SingleCase> createState() => _SingleCaseState();
}

class _SingleCaseState extends State<SingleCase> {
  late Future<CaseDetails> _caseFuture;
  String? caseID;
  late CaseDetails shownCase;
  late CaseProvider provider;
  late UserDetailsProvider userProvider;

  Future<void> loadData() async {
    caseID = ModalRoute.of(context)?.settings.arguments as String?;
    _caseFuture = getCase(caseID!);
  }

  Future<CaseDetails> getCase(String id) async {
    provider = Provider.of<CaseProvider>(context);
    userProvider = Provider.of<UserDetailsProvider>(context);
    try {
      var temp =
          provider.casesDetailed.firstWhere((element) => element.id == id);
      shownCase = temp;
      return temp;
    } on Exception catch (_) {
      return CaseService.getCaseDetailedById(id);
    }
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
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
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
          return _buildMainView();
        }
      },
    );
  }

  Widget _buildMainView() {
    _calcTotalVotes();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  shownCase.title,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                shareCase();
              },
            ),
          ],
        ),
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
            if (shownCase.furtherLinks.isNotEmpty)
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
                    onPressed: () {
                      _launchURL(button.url);
                    },
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
            const SizedBox(height: 5),
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RawMaterialButton(
                  onPressed: () {},
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(10.0),
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.comment,
                    size: 25.0,
                  ),
                ),
                const Spacer(),
                RawMaterialButton(
                  onPressed: () {
                    _vote(-1);
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(10.0),
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.thumb_down,
                    size: 25.0,
                  ),
                ),
                Text(averageVotes.toString()),
                RawMaterialButton(
                  onPressed: () {
                    _vote(1);
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(10.0),
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.thumb_up,
                    size: 25.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  late int averageVotes;

  _launchURL(String link) async {
    await launchUrl(Uri.parse(link));
  }

  void _calcTotalVotes() {
    averageVotes = shownCase.upvotes - shownCase.downvotes;
  }

  void _vote(int vote) async {
    var existingvotes = await SupaBaseConst.supabase
        .from('votes')
        .select('*')
        .match(
            {"case_id": shownCase.id, "user_id": userProvider.currentUser.id});

    if (existingvotes.isNotEmpty) {
      var existingvote = existingvotes.first;
      await SupaBaseConst.supabase
          .from('votes')
          .update({"vote": vote}).match({"id": existingvote["id"]});
    } else {
      await SupaBaseConst.supabase.from('votes').insert({
        'case_id': shownCase.id,
        'user_id': userProvider.currentUser.id,
        'vote': '$vote',
      });
    }

    var temp = await provider.updateDetailedCase(shownCase.id!);
    setState(() {
      shownCase = temp;
      _calcTotalVotes();
    });
  }

  Future<void> shareCase() async {
    final url = 'crimespotter://casedetails/${shownCase.id}';
    try {
      await Share.share(
        'Schau dir diesen Fall bei Crimespotter an: $url',
        subject: 'Teile diesen Fall',
      );
    } catch (error) {
      print('Fehler beim Teilen der Case Details: $error');
    }
  }
}
