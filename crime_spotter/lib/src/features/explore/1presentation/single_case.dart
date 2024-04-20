
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