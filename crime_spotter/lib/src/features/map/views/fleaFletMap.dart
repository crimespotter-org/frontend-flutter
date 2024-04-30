import 'dart:async';
import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:crime_spotter/src/shared/4data/mapProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class OpenStreetMap extends StatefulWidget {
  const OpenStreetMap({super.key});

  @override
  State<OpenStreetMap> createState() => _OpenStreetMapState();
}

class _OpenStreetMapState extends State<OpenStreetMap> {
  final StreamController<void> _rebuildStream = StreamController.broadcast();
  List<WeightedLatLng> data = [];
  List<Map<double, MaterialColor>> gradients = [
    HeatMapOptions.defaultGradient,
    {0.25: Colors.blue, 0.55: Colors.red, 0.85: Colors.pink, 1.0: Colors.purple}
  ];

  var index = 0;

  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
    _rebuildStream.close();
    super.dispose();
  }

  void _incrementCounter() {
    if (mounted) {
      setState(
        () {
          index = index == 0 ? 1 : 0;
          WidgetsBinding.instance.addPostFrameCallback(
            (timeStamp) {
              _rebuildStream.add(null);
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
    setState(
      () {
        data = caseProvider.cases
            .map((e) => WeightedLatLng(LatLng(e.latitude, e.longitude), 10000))
            .toList();
      },
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _rebuildStream.add(null);
      },
    );

    final map = FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(mapProvider.currentPosition.latitude,
            mapProvider.currentPosition.longitude),
        initialZoom: 8.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        if (data.isNotEmpty)
          HeatMapLayer(
            heatMapDataSource: InMemoryHeatMapDataSource(data: data),
            heatMapOptions: HeatMapOptions(
              gradient: gradients[index],
              minOpacity: 0.1,
            ),
            reset: _rebuildStream.stream,
          )
      ],
    );
    return Stack(
      children: [
        Center(child: map),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Farbe ändern',
              child: const Icon(Icons.swap_horiz),
            ),
          ),
        ),
      ],
    );
  }
}
