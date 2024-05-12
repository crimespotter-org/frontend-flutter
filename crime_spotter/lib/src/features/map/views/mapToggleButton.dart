import 'package:crime_spotter/src/features/map/views/mapOption.dart';
import 'package:crime_spotter/src/shared/4data/mapProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

class TMapToggleButton extends StatefulWidget {
  final MapController controller;
  final Map<GeoPoint, List<Placemark>> markers;
  final Map<FilterType, String?> selectedFilte;
  const TMapToggleButton(
      {super.key,
      required this.controller,
      required this.markers,
      required this.selectedFilte});

  @override
  State<TMapToggleButton> createState() => _TMapToggleButtonState();
}

enum ToggleButton { map, heatMap, cases, options }

class _TMapToggleButtonState extends State<TMapToggleButton> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapProvider>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (int index) {
            provider.updateSelectedToggle(index);

            if (index == ToggleButton.options.index) {
              showDialog(
                context: context,
                builder: (context) {
                  return SingleChildScrollView(
                    child: TMapOption(
                      controller: widget.controller,
                      markers: widget.markers,
                      selectedFilter: widget.selectedFilte,
                    ),
                  );
                },
              );
            }
          },
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          selectedBorderColor: Colors.red[700],
          selectedColor: Colors.white,
          fillColor: Colors.red[200],
          color: Colors.red[400],
          constraints: const BoxConstraints(
            minHeight: 40.0,
            minWidth: 80.0,
          ),
          isSelected: provider.selectedToggle,
          children: const [
            Text('Karte'),
            Text('Heatmap'),
            Text('Fallakten'),
            Text('Optionen'),
          ],
        ),
      ],
    );
  }
}
