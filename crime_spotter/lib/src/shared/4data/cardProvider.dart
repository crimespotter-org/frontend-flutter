import 'dart:math';
import 'dart:typed_data';
import 'package:crime_spotter/src/shared/4data/caseService.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum CaseStatus { like, dislike }

class CaseProvider extends ChangeNotifier {
  CaseProvider() {
    resetCases();
  }

  List<Uint8List> _urlImages = [];
  Offset _position = Offset.zero;
  bool _isDragging = false;
  Size _screenSize = Size.zero;
  double _angle = 0;

  List<Uint8List> get urlImages => _urlImages;
  Offset get position => _position;
  bool get isDragging => _isDragging;
  double get angle => _angle;

  void setScreenSize(Size screenSize) => _screenSize = screenSize;

  CaseStatus? getStatus({bool force = false}) {
    final x = _position.dx;

    if (force) {
      const delta = 100;

      if (x >= delta) {
        return CaseStatus.like;
      } else if (x <= -delta) {
        return CaseStatus.dislike;
      }
    } else {
      const delta = 20;
      if (x >= delta) {
        return CaseStatus.like;
      } else if (x <= -delta) {
        return CaseStatus.dislike;
      }
    }
    return null;
  }

  double getStatusOpacity() {
    const delta = 100;

    final pos = max(_position.dx.abs(), _position.dy.abs());
    final opacity = pos / delta;

    return min(opacity, 1);
  }

  void startPosition(DragStartDetails details) {
    _isDragging = true;
    notifyListeners();
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;

    final x = _position.dx;
    _angle = 45 * x / _screenSize.width;

    notifyListeners();
  }

  void endPosition() {
    _isDragging = false;
    notifyListeners();

    final status = getStatus(force: true);

    if (status != null) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: status.toString().split('.').last.toUpperCase(),
        fontSize: 36,
      );
    }

    switch (status) {
      case CaseStatus.like:
        like();
        break;
      case CaseStatus.dislike:
        dislike();
        break;
      default:
        resetPosition();
    }
  }

  void like() {
    _angle = 20;
    _position += Offset(2 * _screenSize.width, 0);
    _nextCase();

    notifyListeners();
  }

  void dislike() {
    _angle = -20;
    _position -= Offset(2 * _screenSize.width, 0);
    _nextCase();

    notifyListeners();
  }

  Future _nextCase() async {
    if (_urlImages.isEmpty) return;

    await Future.delayed(const Duration(milliseconds: 200));
    _urlImages.removeLast();

    resetPosition();
  }

  void resetCases() {
    CaseService.readData().then(
      (value) => {
        _urlImages.addAll(value
            .map((e) => e.images)
            .toList()[1]
            .map((e) => e.image)
            .toList()
            .reversed),
        notifyListeners(),
      },
    );
  }

  void resetPosition() {
    _position = Offset.zero;
    _isDragging = false;
    _angle = 0;

    notifyListeners();
  }
}
