import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:flutter/material.dart';

class CaseTileShort extends StatelessWidget {
  final ExploreCard shownCase;
  Function(BuildContext)? deleteFunction;

  CaseTileShort({
    Key? key,
    required this.shownCase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.asset(
              shownCase.imageUrls.first,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            Container(
              width: double.infinity,
              color: Colors.grey.withOpacity(0.6), // Adjust opacity as needed
              padding: const EdgeInsets.all(8),
              child: Text(
                shownCase.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
