import 'package:crime_spotter/src/features/explore/1presentation/comment_section.dart';
import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/card_provider.dart';
import 'package:crime_spotter/src/shared/4data/case_service.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/4data/supabase_const.dart';
import 'package:crime_spotter/src/shared/4data/userdetails_provider.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  int vote = 0;

  Future<void> loadData(BuildContext context) async {
    caseID = ModalRoute.of(context)?.settings.arguments as String?;

    if (mounted) {
      _caseFuture = getCase(context, caseID!);
    }

    var existingvote = await SupaBaseConst.supabase
        .from('votes')
        .select('*')
        .match({"case_id": caseID, "user_id": userProvider.currentUser.id});

    if (existingvote.isNotEmpty) {
      vote = existingvote.first['vote'];
    }
    setState(() {});
  }

  Future<CaseDetails> getCase(BuildContext context, String id) async {
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
    provider = Provider.of<CaseProvider>(context);
    userProvider = Provider.of<UserDetailsProvider>(context);
    loadData(context);
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
          return _buildMainView(context);
        }
      },
    );
  }

  Widget _buildMainView(BuildContext context) {
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
                shareCase().then(
                  (successful) => {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(successful
                            ? 'Der Fall wurde versendet!'
                            : 'Fehler beim Teilen der Falldetails!'),
                        backgroundColor: successful ? Colors.green : Colors.red,
                      ),
                    ),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
                      fillColor: TColor.buttonColor,
                      padding: const EdgeInsets.all(10.0),
                      shape: const CircleBorder(),
                      child: Icon(
                        iconData,
                        size: 25.0,
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 10),
            DefaultTextStyle.merge(
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              child: const Center(
                child: Text(
                  'Zusammenfassung:',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
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
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(
              color: Colors.white,
              indent: 16,
              endIndent: 16,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Row(
                            children: [
                              const Text(
                                "Typ: ",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                TDeviceUtil.convertCaseTypeToGerman(
                                    shownCase.caseType),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              const Text(
                                "Status: ",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                TDeviceUtil.convertCaseStatusToGerman(
                                    shownCase.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "Ort: ",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "${shownCase.zipCode.toString()} ${shownCase.placeName}",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "Tatdatum: ",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('dd.MM.yyyy')
                            .format(shownCase.crimeDateTime),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RawMaterialButton(
                  onPressed: () {
                    _displayCommentSection(context);
                  },
                  elevation: 2.0,
                  fillColor: TColor.buttonColor,
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
                  fillColor: vote == -1 ? Colors.redAccent : TColor.buttonColor,
                  padding: const EdgeInsets.all(10.0),
                  shape: const CircleBorder(),
                  child: const Icon(
                    Icons.thumb_down,
                    size: 25.0,
                  ),
                ),
                Text(
                  averageVotes.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                RawMaterialButton(
                  onPressed: () {
                    _vote(1);
                  },
                  elevation: 2.0,
                  fillColor:
                      vote == 1 ? Colors.greenAccent : TColor.buttonColor,
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

  void _vote(int newvote) async {
    var existingvotes = await SupaBaseConst.supabase
        .from('votes')
        .select('*')
        .match(
            {"case_id": shownCase.id, "user_id": userProvider.currentUser.id});

    if (existingvotes.isNotEmpty) {
      var existingvote = existingvotes.first;
      if (existingvote['vote'] == newvote) {
        await SupaBaseConst.supabase
            .from('votes')
            .delete()
            .match({"id": existingvote["id"]});
        newvote = 0;
      } else {
        await SupaBaseConst.supabase
            .from('votes')
            .update({"vote": newvote}).match({"id": existingvote["id"]});
      }
    } else {
      await SupaBaseConst.supabase.from('votes').insert({
        'case_id': shownCase.id,
        'user_id': userProvider.currentUser.id,
        'vote': '$newvote',
      });
    }

    var temp = await provider.updateDetailedCase(shownCase.id!);
    setState(() {
      vote = newvote;
      shownCase = temp;
      _calcTotalVotes();
    });
  }

  Future<bool> shareCase() async {
    final url = 'crimespotter://casedetails/?${shownCase.id}';
    try {
      await Share.share(
        'Schau dir diesen Fall bei Crimespotter an: $url',
        subject: 'Teile diesen Fall',
      );
      return true;
    } catch (error) {
      return false;
    }
  }

  Future _displayCommentSection(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      //backgroundColor: Colors.blue,
      barrierColor: Colors.black87.withOpacity(0.4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return CommentSection(shownCase: shownCase);
      },
    );
  }
}
