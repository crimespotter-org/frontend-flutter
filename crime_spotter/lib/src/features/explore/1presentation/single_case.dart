import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:flutter/material.dart';

class Single_case extends StatefulWidget {
  const Single_case({super.key});

  @override
  State<Single_case> createState() => _Single_caseState();
}

class _Single_caseState extends State<Single_case> {
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
            if (shownCase.imageUrls.length < 2)
              SizedBox(
                height: 300,
                child: Image.asset(
                  shownCase.imageUrls.first,
                  width: 300.0,
                  height: 300.0,
                  fit: BoxFit.contain,
                ),
              )
            else
              PageView.builder(
                itemCount: shownCase.imageUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    shownCase.imageUrls[index],
                    fit: BoxFit.cover, // Adjust the image fit as needed
                  );
                },
              ),
            if (shownCase.buttons != null && shownCase.buttons!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: shownCase.buttons!.map((button) {
                  IconData iconData;
                  switch (button.type) {
                    case "default":
                      iconData = Icons.disabled_by_default;
                      break;
                    case "podcast":
                      iconData = Icons.headphones;
                      break;
                    case "newspaper":
                      iconData = Icons.newspaper;
                      break;
                    case "test":
                      iconData = Icons.library_books;
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
            Container(
              margin: EdgeInsets.only(top: 10),
              child: DefaultTextStyle.merge(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                child: const Center(
                  child: Text('Summary:'),
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

// GestureDetector(
//               onHorizontalDragEnd: (details) {
//                 if (details.primaryVelocity! > 0 && currentIndex > 0) {
//                   setState(() {
//                     currentIndex--;
//                   });
//                 } else if (details.primaryVelocity! < 0 &&
//                     currentIndex < cases.length - 1) {
//                   setState(() {
//                     currentIndex++;
//                   });
//                 }
//               },
//               child: Card(
//                 child: Column(
//                   children: [
//                     if (cases[currentIndex]
//                         .imageUrls
//                         .first
//                         .contains("placeholder"))
//                       SizedBox(
//                         height: 300,
//                         child: Image.asset(
//                           'assets/placeholder.jpg',
//                           width: 300.0,
//                           height: 300.0,
//                           fit: BoxFit.contain,
//                         ),
//                       )
//                     else
//                       PageView.builder(
//                         itemCount: cases[currentIndex].imageUrls.length,
//                         itemBuilder: (context, index) {
//                           return Image.network(
//                             cases[currentIndex].imageUrls[index],
//                             fit: BoxFit.cover, // Adjust the image fit as needed
//                           );
//                         },
//                       ),
//                     if (cases[currentIndex].buttons != null &&
//                         cases[currentIndex].buttons!.isNotEmpty)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: cases[currentIndex].buttons!.map((button) {
//                           IconData iconData;
//                           switch (button.type) {
//                             case "default":
//                               iconData = Icons.disabled_by_default;
//                               break;
//                             case "podcast":
//                               iconData = Icons.headphones;
//                               break;
//                             case "newspaper":
//                               iconData = Icons.newspaper;
//                               break;
//                             case "test":
//                               iconData = Icons.library_books;
//                               break;
//                             default:
//                               iconData =
//                                   Icons.error; // or any other default icon
//                           }

//                           return RawMaterialButton(
//                             onPressed: () {},
//                             elevation: 2.0,
//                             fillColor: Colors.white,
//                             padding: const EdgeInsets.all(10.0),
//                             shape: const CircleBorder(),
//                             child: Icon(
//                               iconData,
//                               size: 25.0,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     Container(
//                       margin: EdgeInsets.only(top: 10),
//                       child: DefaultTextStyle.merge(
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         child: const Center(
//                           child: Text('Summary:'),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: SingleChildScrollView(
//                         padding: const EdgeInsets.all(16.0),
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.vertical,
//                           child: Text(
//                             cases[currentIndex].text,
//                             textAlign: TextAlign.justify,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )