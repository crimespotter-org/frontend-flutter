import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:flutter/material.dart';

class SingleCase extends StatefulWidget {
  const SingleCase({super.key});

  @override
  State<SingleCase> createState() => _SingleCaseState();
}

class _SingleCaseState extends State<SingleCase> {
  @override
  Widget build(BuildContext context) {
    final shownCase =
        ModalRoute.of(context)!.settings.arguments as ExploreCardData;
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
            if (shownCase.furtherLinks != null &&
                shownCase.furtherLinks!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: shownCase.furtherLinks!.map((button) {
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
                child: Text('Summary:'),
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
