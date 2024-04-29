import 'package:flutter/material.dart';

class MapProvider extends ChangeNotifier {
  MapProvider() {
    changeToMap();
  }
  bool _isHeatMap = false;
  bool _showSwipeableCases = false;
  bool _mapLoaded = false;

  bool get isHeatmap => _isHeatMap;
  bool get showSwipeableCases => _showSwipeableCases;
  bool get mapLoaded => _mapLoaded;

  void showCases() {
    _showSwipeableCases = true;
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
