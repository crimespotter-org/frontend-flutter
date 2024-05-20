import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:flutter/material.dart';

class CaseTileShort extends StatelessWidget {
  final CaseDetails shownCase;
  final bool canEdit;
  Function(BuildContext)? deleteFunction;

  CaseTileShort({
    super.key,
    required this.shownCase,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.pushNamed(context, UIData.singleCase,
            arguments: shownCase.id);
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 15),
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              shownCase.images.isEmpty
                  ? Image.asset(
                      "assets/placeholder.jpg",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      //opacity: const AlwaysStoppedAnimation(.6),
                    )
                  : Image.memory(
                      shownCase.images.first.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      //opacity: const AlwaysStoppedAnimation(.6),
                    ),
              Container(
                width: double.infinity,
                color: const Color.fromARGB(200, 0, 0, 0),
                padding: const EdgeInsets.all(8),
                child: Text(
                  shownCase.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    children: [
                      const Spacer(),
                      if (canEdit)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          iconSize: 50,
                          color: Colors.redAccent,
                          onPressed: () async {
                            Navigator.pushNamed(context, UIData.editCase,
                                arguments: shownCase.id);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
