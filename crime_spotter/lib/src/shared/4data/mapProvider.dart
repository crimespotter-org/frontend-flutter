import 'package:crime_spotter/src/features/map/views/mapToggleButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

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
    false, //cases
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
    } else if (index == ToggleButton.cases.index) {
      _changeToMap();
      showCases();
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

  _changeToMap() {
    _isHeatMap = false;
    notifyListeners();
  }

  _changeToHeatMap() {
    _isHeatMap = true;
    notifyListeners();
  }
}
