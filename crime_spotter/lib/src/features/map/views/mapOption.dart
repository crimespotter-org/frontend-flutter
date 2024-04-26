import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class TMapOption extends StatefulWidget {
  final MapController controller;
  const TMapOption({super.key, required this.controller});

  @override
  State<TMapOption> createState() => _TMapOptionState();
}

class _TMapOptionState extends State<TMapOption> {
  final double? spaceBetweenOptions = 8;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Optionen',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Divider(
                    thickness: 3,
                  ),
                  buildMapOptions(),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.clear),
            )
          ],
        ),
      ),
    );
  }

  Widget buildMapOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Karternoptionen',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        buildDivider(text: 'Kartenoptionen'),
        const Text(
          'Karternoptionen',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          height: spaceBetweenOptions,
        ),
        const Text(
          'Karternoptionen',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          height: spaceBetweenOptions,
        ),
        const Text(
          'Karternoptionen',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          height: spaceBetweenOptions,
        ),
        const Text(
          'Karternoptionen',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          height: spaceBetweenOptions,
        ),
      ],
    );
  }

  Widget buildDivider({required String text}) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider()),
        const SizedBox(
          width: 5,
        ),
        Text(text),
        const SizedBox(
          width: 5,
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
