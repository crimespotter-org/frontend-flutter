import 'package:crime_spotter/src/features/map/views/map_toggle_button.dart';
import 'package:crime_spotter/src/shared/4data/card_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';

class MapProvider extends ChangeNotifier {
  MapProvider() {
    _changeToMap();
  }
  bool _isHeatMap = false;
  bool _showSwipeableCases = false;
  bool _mapLoaded = false;
  GeoPoint _currentPosition = GeoPoint(latitude: 0, longitude: 0);
  final List<bool> _selectedToggle = <bool>[
    true, //map
    false, //heatmap
    false //options
  ];

  bool get isHeatmap => _isHeatMap;
  bool get showSwipeableCases => _showSwipeableCases;
  bool get mapLoaded => _mapLoaded;
  GeoPoint get currentPosition => _currentPosition;
  List<bool> get selectedToggle => _selectedToggle;

  void showCases() {
    _showSwipeableCases = true;
    notifyListeners();
  }

  void updateSelectedToggle(int index) {
    for (int i = 0; i < _selectedToggle.length; i++) {
      _selectedToggle[i] = i == index;
    }

    if (index == ToggleButton.map.index) {
      _changeToMap();
      hideCases();
    } else if (index == ToggleButton.heatMap.index) {
      _changeToHeatMap();
      hideCases();
    } else if (index == ToggleButton.options.index) {
      _changeToMap();
      hideCases();
    }
    notifyListeners();
  }

  void updateCurrentPosition(GeoPoint position) {
    _currentPosition = position;
    notifyListeners();
  }

  void mapIsLoaded() {
    _mapLoaded = true;
    notifyListeners();
  }

  void unloadMap() {
    _mapLoaded = false;
    notifyListeners();
  }

  void hideCases() {
    _showSwipeableCases = false;
    notifyListeners();
  }

  Future<Map<GeoPoint, List<Placemark>>> rebuildInitialMarker(
      {required MapController controller,
      required CaseProvider caseProvider,
      required Map<GeoPoint, List<Placemark>> markers}) async {
    //Erst alle Case-Marker löschen
    for (var singleCase in caseProvider.cases) {
      var currentPosition = GeoPoint(
          latitude: singleCase.latitude, longitude: singleCase.longitude);
      controller.removeMarker(currentPosition);
      markers.removeWhere((key, value) => key == currentPosition);
    }

    //Alle gefilterten Cases wieder hinzufügen
    for (var singleCase in caseProvider.filteredCases) {
      GeoPoint currentPosition = GeoPoint(
          latitude: singleCase.latitude, longitude: singleCase.longitude);

      await controller.addMarker(
        currentPosition,
        markerIcon: buildMarker(singleCase.caseType),
      );
      placemarkFromCoordinates(singleCase.latitude, singleCase.longitude).then(
        (value) => {
          if (value.isNotEmpty)
            {
              markers[GeoPoint(
                  latitude: singleCase.latitude,
                  longitude: singleCase.longitude)] = value
            },
        },
      );
    }
    return markers;
  }

  MarkerIcon buildMarker(CaseType type) {
    IconData icon;
    MaterialColor color;

    switch (type) {
      case CaseType.murder:
        icon = Icons.directions_run;
        color = Colors.red;
        break;
      case CaseType.theft:
        icon = Icons.report;
        color = Colors.grey;
        break;
      case CaseType.robberyMurder:
        icon = Icons.local_atm;
        color = Colors.green;
        break;
      case CaseType.brawl:
        icon = Icons.groups;
        color = Colors.brown;
        break;
      case CaseType.rape:
        icon = Icons.pan_tool;
        color = Colors.purple;
        break;
      default:
        icon = Icons.pin_drop;
        color = Colors.blue;
        break;
    }
    return MarkerIcon(
      icon: Icon(
        icon,
        color: color,
        size: 48,
      ),
    );
  }

  _changeToMap() {
    _isHeatMap = false;
    notifyListeners();
  }

  _changeToHeatMap() {
    _isHeatMap = true;
    notifyListeners();
  }
}
