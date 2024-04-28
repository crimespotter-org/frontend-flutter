import 'package:crime_spotter/src/features/map/views/mapOption.dart';
import 'package:crime_spotter/src/shared/4data/mapProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:provider/provider.dart';

class TMapToggleButton extends StatefulWidget {
  final MapController controller;
  const TMapToggleButton({super.key, required this.controller});

  @override
  State<TMapToggleButton> createState() => _TMapToggleButtonState();
}

enum ToggleButton { map, heatMap, cases, options }

class _TMapToggleButtonState extends State<TMapToggleButton> {
  final List<bool> _selectedToggle = <bool>[true, false, false, false];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapProvider>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ToggleButtons(
          direction: Axis.horizontal,
          onPressed: (int index) {
            if (mounted) {
              setState(
                () {
                  for (int i = 0; i < _selectedToggle.length; i++) {
                    _selectedToggle[i] = i == index;
                  }
                },
              );
            }

            if (index == ToggleButton.map.index) {
              provider.changeToMap();
              provider.hideCases();
            } else if (index == ToggleButton.heatMap.index) {
              provider.changeToHeatMap();
              provider.hideCases();
            } else if (index == ToggleButton.cases.index) {
              provider.changeToMap();
              provider.showCases();
            } else if (index == ToggleButton.options.index) {
              provider.changeToMap();
              provider.hideCases();

              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return TMapOption(controller: widget.controller);
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
          isSelected: _selectedToggle,
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
