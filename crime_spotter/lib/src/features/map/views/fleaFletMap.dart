import 'dart:async';
import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class OpenStreetMap extends StatefulWidget {
  final MapController controller;
  const OpenStreetMap({super.key, required this.controller});

  @override
  State<OpenStreetMap> createState() => _OpenStreetMapState();
}

class _OpenStreetMapState extends State<OpenStreetMap> {
  LatLng currentLocation = const LatLng(48.769, 9.02);
  List<WeightedLatLng> data = [];

  Future<LatLng> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(
        () {
          currentLocation = LatLng(position.latitude, position.longitude);
          //controller.move(currentLocation, 15);
        },
      );
    }
    return currentLocation;
  }

  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
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

    return Stack(
      children: [
        Center(
          child: FlutterMap(
            mapController: widget.controller,
            options: MapOptions(
              initialCenter: currentLocation,
              initialZoom: 8.0,
              // onMapReady: () async => {
              //   currentLocation = await _getCurrentLocation(),
              //   widget.controller.move(currentLocation, 15),
              // },
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
                )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              onPressed: () async => {
                currentLocation = await _getCurrentLocation(),
                widget.controller.move(currentLocation, 15),
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
