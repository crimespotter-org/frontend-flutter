import 'dart:math';
import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/caseService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CaseVoting { like, dislike }

enum CaseType { murder, theft, robberyMurder, brawl, rape }

enum CaseStatus { open, closed }

class CaseProvider extends ChangeNotifier {
  CaseProvider() {
    resetCases();
  }

  final List<CaseDetails> _cases = [];
  final List<CaseDetails> _filteredCases = [];
  final List<Uint8List> _casesForVoting = [];
  Offset _position = Offset.zero;
  bool _isDragging = false;
  Size _screenSize = Size.zero;
  double _angle = 0;

  List<CaseDetails> get cases => _cases;
  List<CaseDetails> get filteredCases => _filteredCases;
  List<Uint8List> get casesForVoting => _casesForVoting;
  Offset get position => _position;
  bool get isDragging => _isDragging;
  double get angle => _angle;

  void setScreenSize(Size screenSize) => _screenSize = screenSize;

  CaseType getCrimeTypeFromString(String crimeString) {
    switch (crimeString) {
      case "murder":
        return CaseType.murder;
      case "theft":
        return CaseType.theft;
      case "robbery-murder":
        return CaseType.robberyMurder;
      case "brawl":
        return CaseType.brawl;
      case "rape":
        return CaseType.rape;
      default:
        throw Exception("Ungültiger Verbrechens-Typ: $crimeString");
    }
  }

  CaseVoting? getStatus({bool force = false}) {
    final x = _position.dx;

    if (force) {
      const delta = 100;

      if (x >= delta) {
        return CaseVoting.like;
      } else if (x <= -delta) {
        return CaseVoting.dislike;
      }
    } else {
      const delta = 20;
      if (x >= delta) {
        return CaseVoting.like;
      } else if (x <= -delta) {
        return CaseVoting.dislike;
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

    switch (status) {
      case CaseVoting.like:
        like();
        break;
      case CaseVoting.dislike:
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
    if (_casesForVoting.isEmpty) return;

    await Future.delayed(const Duration(milliseconds: 200));
    _casesForVoting.removeLast();

    resetPosition();
  }

  void resetCases() {
    _cases.clear();
    _filteredCases.clear();
    _casesForVoting.clear();

    CaseService.getAllCases().then(
      (value) => {
        _cases.addAll(value.reversed),
        _filteredCases.addAll(value.reversed),
        notifyListeners(),
      },
    );
    CaseService.getCasesIncludingFirstImage().then(
      (value) => {
        _casesForVoting.addAll(
          value
              .expand<Uint8List>((element) => element.images
                  .where((element) => element.image.isNotEmpty)
                  .map((e) => e.image))
              .toList(),
        ),
        notifyListeners(),
      },
    );
  }

  void filterTitlesAndSummary(String filter, bool deletFilter) {
    if (deletFilter) {
      _filteredCases.map((e) => e.title.contains(filter)).toList(); //TODO
    } else {
      _filteredCases
          .map((e) => e.title.contains(filter) || e.summary.contains(filter))
          .toList();
    }
  }

  void filterCreatedBy(String filter, bool deletFilter) {
    if (deletFilter) {
      _filteredCases.map((e) => e.createdBy.contains(filter)).toList(); //TODO
    } else {
      _filteredCases.map((e) => e.createdBy.contains(filter)).toList();
    }
  }

  void filterCreatedAt(DateTime filter, bool deletFilter) {
    if (deletFilter) {
      _filteredCases.map((e) => e.createdAt == filter).toList(); //TODO
    } else {
      _filteredCases.map((e) => e.createdAt == filter).toList();
    }
  }

  void filterPlaceName(String filter, bool deletFilter) {
    if (deletFilter) {
      _filteredCases.map((e) => e.placeName.contains(filter)).toList(); //TODO
    } else {
      _filteredCases.map((e) => e.placeName.contains(filter)).toList();
    }
  }

  void filterZipName(String filter, bool deletFilter) {
    if (deletFilter) {
      _filteredCases
          .map((e) => (e.zipCode as String).contains(filter))
          .toList(); //TODO
    } else {
      _filteredCases
          .map((e) => (e.zipCode as String).contains(filter))
          .toList();
    }
  }

  void filterCaseType(CaseType filter, bool deletFilter) {
    if (deletFilter) {
      _filteredCases.map((r) => r.caseType == filter as String).toList(); //TODO
    } else {
      _filteredCases.map((r) => r.caseType == filter as String).toList();
    }
  }

  void filterCrimeDate(DateTime filter, bool deletFilter) {
    if (deletFilter) {
      _filteredCases.map((e) => e.crimeDateTime == filter).toList(); //TODO
    } else {
      _filteredCases.map((e) => e.crimeDateTime == filter).toList();
    }
  }

  void filterCaseStatus(CaseStatus filter, bool deletFilter) {
    if (deletFilter) {
      _filteredCases.map((e) => e.status == filter as String).toList(); //TODO
    } else {
      _filteredCases.map((e) => e.status == filter as String).toList();
    }
  }

  void resetPosition() {
    _position = Offset.zero;
    _isDragging = false;
    _angle = 0;

    notifyListeners();
  }
}
