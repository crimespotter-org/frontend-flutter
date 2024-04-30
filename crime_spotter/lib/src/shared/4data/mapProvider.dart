import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapProvider extends ChangeNotifier {
  MapProvider() {
    changeToMap();
  }
  bool _isHeatMap = false;
  bool _showSwipeableCases = false;
  bool _mapLoaded = false;
  GeoPoint _currentPosition = GeoPoint(latitude: 0, longitude: 0);

  bool get isHeatmap => _isHeatMap;
  bool get showSwipeableCases => _showSwipeableCases;
  bool get mapLoaded => _mapLoaded;
  GeoPoint get currentPosition => _currentPosition;

  void showCases() {
    _showSwipeableCases = true;
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

  void changeToMap() {
    _isHeatMap = false;
    notifyListeners();
  }

  void changeToHeatMap() {
    _isHeatMap = true;
    notifyListeners();
  }
}
