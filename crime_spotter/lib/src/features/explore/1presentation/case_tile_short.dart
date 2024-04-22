import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:flutter/material.dart';

class CaseTileShort extends StatelessWidget {
  final ExploreCardData shownCase;
  Function(BuildContext)? deleteFunction;

  CaseTileShort({
    super.key,
    required this.shownCase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            shownCase.imageUrls.isEmpty
                ? const Placeholder()
                : Image.memory(
                    shownCase.imageUrls.first,
                    fit: BoxFit.cover,
                  ),
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 202, 202, 202)
                  .withOpacity(0.6), // Adjust opacity as needed
              padding: const EdgeInsets.all(8),
              child: Text(
                shownCase.title,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: 140,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        iconSize: 50,
                        color: Colors.red,
                        onPressed: () async {
                          Navigator.pushNamed(context, UIData.edit_case,
                              arguments: shownCase);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        iconSize: 50,
                        color: Colors.red,
                        onPressed: () async {
                          Navigator.pushNamed(context, UIData.single_case,
                              arguments: shownCase);
                        },
                      ),
                    ],
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
