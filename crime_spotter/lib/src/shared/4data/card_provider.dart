import 'dart:math';
import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/case_service.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/4data/userdetails_provider.dart';
import 'package:crime_spotter/src/shared/model/active_user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CaseVoting { like, dislike }

enum CaseType { murder, theft, robberyMurder, brawl, rape }

enum CaseTypeNullable { murder, theft, robberyMurder, brawl, rape, none }

enum CaseStatus { open, closed }

enum CaseStatusNullable { open, closed, none }

class CaseProvider extends ChangeNotifier {
  CaseProvider() {
    resetCases();
  }

  final List<CaseDetails> _casesDetailed = [];
  final List<CaseDetails> _filteredCasesExploreView = [];
  List<CaseDetails> _cases = [];
  List<CaseDetails> _filteredCases = [];
  List<Uint8List> _casesForVoting = [];
  Offset _position = Offset.zero;
  bool _isDragging = false;
  Size _screenSize = Size.zero;
  double _angle = 0;

  List<CaseDetails> get cases => _cases;
  List<CaseDetails> get casesDetailed => _casesDetailed;
  List<CaseDetails> get filteredCases => _filteredCases;
  List<CaseDetails> get filteredCasesExploreView => _filteredCasesExploreView;
  List<Uint8List> get casesForVoting => _casesForVoting;
  Offset get position => _position;
  bool get isDragging => _isDragging;
  double get angle => _angle;

  void setScreenSize(Size screenSize) => _screenSize = screenSize;

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
    _casesDetailed.clear();
    _filteredCases.clear();
    _casesForVoting.clear();
    _filteredCasesExploreView.clear();

    CaseService.getAllCases()
        .then(
          (value) => {
            _cases = value.reversed.toList(),
            _filteredCases = value.reversed.toList(),
            notifyListeners(),
          },
        )
        .then(
          (value) => {
            for (CaseDetails c in _cases)
              {
                CaseService.getCaseDetailedById(c.id!).then(
                  (value) => {
                    _casesDetailed.add(value),
                    _casesDetailed.sort((a, b) => a.title.compareTo(b.title)),
                    _filteredCasesExploreView.add(value),
                    _filteredCasesExploreView
                        .sort((a, b) => a.title.compareTo(b.title)),
                    notifyListeners(),
                  },
                ),
              },
          },
        );
    CaseService.getCasesIncludingFirstImage().then(
      (value) => {
        _casesForVoting = value
            .expand<Uint8List>((element) => element.images
                .where((element) => element.image.isNotEmpty)
                .map((e) => e.image))
            .toList(),
        notifyListeners(),
      },
    );
  }

  Future<CaseDetails> updateDetailedCase(String caseID) async {
    await CaseService.getCaseDetailedById(caseID).then(
      (value) {
        int index =
            _casesDetailed.indexWhere((element) => element.id == caseID);
        if (index != -1) {
          _casesDetailed[index] = value;
        }
      },
    );
    return _casesDetailed.firstWhere((element) => element.id == caseID);
  }

  void applyFilter(
      {DateTime? createdAt,
      String? title,
      String? createdBy,
      String? placeName,
      CaseType? type,
      CaseStatus? status}) {
    _filteredCases.clear();

    _filteredCases.addAll(
      _cases
          .where(
            (element) =>
                (createdAt != null ? element.createdAt == createdAt : true) &&
                (createdBy != null ? element.createdBy == createdBy : true) &&
                (type != null ? element.caseType == type : true) &&
                (status != null ? element.status == status : true) &&
                ((title != null && title != '')
                    ? element.title.toLowerCase().contains(title.toLowerCase())
                    : true) &&
                ((placeName != null && placeName != '')
                    ? element.placeName
                        .toLowerCase()
                        .contains(placeName.toLowerCase())
                    : true),
          )
          .toList(),
    );
  }

  void resetPosition() {
    _position = Offset.zero;
    _isDragging = false;
    _angle = 0;

    notifyListeners();
  }

  void removeCaseFromLists(String idToRemove) {
    _cases.removeWhere((element) => element.id == idToRemove);
    _casesDetailed.removeWhere((element) => element.id == idToRemove);
    _filteredCases.removeWhere((element) => element.id == idToRemove);
    _filteredCasesExploreView
        .removeWhere((element) => element.id == idToRemove);
  }

  void filterForExplore(
      {required UserDetailsProvider userProvider,
      DateTime? createdAt,
      String? title,
      String? createdBy,
      String? placeName,
      CaseTypeNullable? type,
      CaseStatusNullable? status}) {
    _filteredCasesExploreView.clear();
    DateTime? startOfDay;
    DateTime? endOfDay;
    Iterable<ActiveUser>? users;

    if (createdAt != null) {
      startOfDay = DateTime(createdAt.year, createdAt.month, createdAt.day)
          .subtract(const Duration(hours: 1));
      endOfDay = startOfDay.add(const Duration(days: 1));
    }
    if (createdBy != null) {
      users = userProvider.activeUsersIncludingCurrent.where((element) =>
          element.name.toLowerCase().contains(createdBy.toLowerCase()));
    }

    _filteredCasesExploreView.addAll(
      _casesDetailed
          .where(
            (element) =>
                (createdAt != null
                    ? element.crimeDateTime.isAfter(startOfDay!) &&
                        element.crimeDateTime.isBefore(endOfDay!)
                    : true) &&
                (title != null && title.isNotEmpty
                    ? element.title.toLowerCase().contains(title.toLowerCase())
                    : true) &&
                (createdBy != null && createdBy.isNotEmpty && users != null
                    ? users.any((user) => user.id
                        .toLowerCase()
                        .contains(element.createdBy.toLowerCase()))
                    : true) &&
                (placeName != null && placeName.isNotEmpty
                    ? element.placeName
                        .toLowerCase()
                        .contains(placeName.toLowerCase())
                    : true) &&
                (type != null && type != CaseTypeNullable.none
                    ? element.caseType ==
                        TDeviceUtil.convertNullableCaseTypeToCaseType(type)
                    : true) &&
                (status != null && status != CaseStatusNullable.none
                    ? element.status ==
                        TDeviceUtil.convertNullableCaseStatusToCaseStatus(
                            status)
                    : true),
          )
          .toList(),
    );
  }
}
