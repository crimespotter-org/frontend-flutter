import 'dart:async';
import 'dart:convert';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMap extends StatefulWidget {
  final osm.MapController controller;
  const OpenStreetMap({super.key, required this.controller});

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
    _loadData();
    super.initState();
  }

  @override
  dispose() {
    _rebuildStream.close();
    super.dispose();
  }

  Future<void> _loadData() async {
    await rootBundle.loadString('assets/initial_data.json').then(
          (value) => {
            setState(
              () {
                data = (jsonDecode(value) as List<dynamic>)
                    .map((e) => e as List<dynamic>)
                    .map((e) => WeightedLatLng(LatLng(e[0], e[1]), 1))
                    .toList();
              },
            ),
          },
        );
  }

  void _incrementCounter() {
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

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _rebuildStream.add(null);
      },
    );

    final map = FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(57.8827, -6.0400),
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
          padding: EdgeInsets.all(20),
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
