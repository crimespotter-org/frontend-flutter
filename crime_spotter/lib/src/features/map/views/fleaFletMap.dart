import 'dart:async';
import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:geolocator/geolocator.dart';
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
  // List<Map<double, MaterialColor>> gradients = [
  //   HeatMapOptions.defaultGradient,
  //   {0.25: Colors.blue, 0.55: Colors.red, 0.85: Colors.pink, 1.0: Colors.purple}
  // ];

  LatLng currentLocation = const LatLng(0, 0);

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(
      () {
        currentLocation = LatLng(position.latitude, position.longitude);
      },
    );
  }

  @override
  initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  dispose() {
    _rebuildStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
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

    final controller = MapController();
    return Stack(
      children: [
        Center(
          child: FlutterMap(
            mapController: controller,
            options: MapOptions(
              initialCenter: currentLocation,
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
                    gradient: HeatMapOptions.defaultGradient,
                    minOpacity: 0.1,
                  ),
                  reset: _rebuildStream.stream,
                )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              onPressed: () {
                controller.move(currentLocation, 13.0);
              },
              tooltip: 'Aktueller Standort',
              child: const Icon(Icons.my_location),
            ),
          ),
        ),
      ],
    );
  }
}
