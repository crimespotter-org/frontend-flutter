import 'package:flutter/material.dart';

class MapProvider extends ChangeNotifier {
  MapProvider() {
    changeToMap();
  }
  bool _isHeatMap = false;
  bool _showSwipeableCases = false;

  bool get isHeatmap => _isHeatMap;
  bool get showSwipeableCases => _showSwipeableCases;

  void showCases() {
    _showSwipeableCases = true;
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
