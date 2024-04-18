import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class TMap extends StatelessWidget {
  TMap({
    super.key,
  });
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  final MapType _mapType = MapType.none;
  Position startposition = Position(
      latitude: 48.44548688211155,
      longitude: 8.696868994581505,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(startposition.latitude, startposition.longitude),
        zoom: 13,
      ),
      mapType: _mapType,
      markers: Set<Marker>.of(_markers),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      zoomControlsEnabled: false,
    );
  }
}
