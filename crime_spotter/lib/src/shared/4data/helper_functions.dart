import 'package:crime_spotter/src/shared/4data/card_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TDeviceUtil {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size getScreenSize() {
    return MediaQuery.of(Get.context!).size;
  }

  static double getScreenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static const Map<String, CaseType> stringToCaseTypeMap = {
    "Mord": CaseType.murder,
    "murder": CaseType.murder,
    "Diebstahl": CaseType.theft,
    "theft": CaseType.theft,
    "Tote bei Raub": CaseType.robberyMurder,
    "robbery-murder": CaseType.robberyMurder,
    "Schlägerei": CaseType.brawl,
    "brawl": CaseType.brawl,
    "Vergewaltigung": CaseType.rape,
    "rape": CaseType.rape,
  };

  static const Map<CaseType, String> caseTypeToStringMap = {
    CaseType.murder: 'murder',
    CaseType.theft: 'theft',
    CaseType.robberyMurder: 'robbery-murder',
    CaseType.brawl: 'brawl',
    CaseType.rape: 'rape',
  };

  static const Map<CaseType, String> caseTypeToGermanMap = {
    CaseType.murder: 'Mord',
    CaseType.theft: 'Diebstahl',
    CaseType.robberyMurder: 'Tote bei Raub',
    CaseType.brawl: 'Schlägerei',
    CaseType.rape: 'Vergewaltigung',
  };

  static CaseType? convertStringToCaseType(String? crimeString) {
    return stringToCaseTypeMap[crimeString];
  }

  static String? convertCaseTypeToString(CaseType type) {
    return caseTypeToStringMap[type];
  }

  static String convertCaseTypeToGerman(CaseType type) {
    return caseTypeToGermanMap[type] ?? 'Mord';
  }

  static CaseStatus? convertStringToCaseStatus(String? status) {
    switch (status) {
      case 'open':
      case 'Offen':
        return CaseStatus.open;
      case 'closed':
      case 'Geschlossen':
      case 'Abgeschlossen':
        return CaseStatus.closed;
      default:
        return null;
    }
  }

  static String? convertCaseStatusToString(CaseStatus? status) {
    switch (status) {
      case CaseStatus.open:
        return 'open';
      case CaseStatus.closed:
        return 'closed';
      default:
        return null;
    }
  }

  static String convertNullableCaseTypeToGerman(CaseTypeNullable type) {
    switch (type) {
      case CaseTypeNullable.murder:
        return 'Mord';
      case CaseTypeNullable.theft:
        return 'Diebstahl';
      case CaseTypeNullable.robberyMurder:
        return 'Tote bei Raub';
      case CaseTypeNullable.brawl:
        return 'Schlägerei';
      case CaseTypeNullable.rape:
        return 'Vergewaltigung';
      case CaseTypeNullable.none:
        return '-';
      default:
        return '-';
    }
  }

  static CaseType convertNullableCaseTypeToCaseType(CaseTypeNullable type) {
    switch (type) {
      case CaseTypeNullable.murder:
        return CaseType.murder;
      case CaseTypeNullable.theft:
        return CaseType.theft;
      case CaseTypeNullable.robberyMurder:
        return CaseType.robberyMurder;
      case CaseTypeNullable.brawl:
        return CaseType.brawl;
      case CaseTypeNullable.rape:
        return CaseType.rape;
      default:
        return CaseType.murder;
    }
  }

  static String convertCaseStatusToGerman(CaseStatus status) {
    switch (status) {
      case CaseStatus.open:
        return 'Offen';
      case CaseStatus.closed:
        return 'Geschlossen';
      default:
        return 'Offen';
    }
  }

  static String convertNullableCaseStatusToGerman(CaseStatusNullable status) {
    switch (status) {
      case CaseStatusNullable.open:
        return 'Offen';
      case CaseStatusNullable.closed:
        return 'Geschlossen';
      case CaseStatusNullable.none:
        return '-';
      default:
        return '-';
    }
  }

  static CaseStatus convertNullableCaseStatusToCaseStatus(
      CaseStatusNullable status) {
    switch (status) {
      case CaseStatusNullable.open:
        return CaseStatus.open;
      case CaseStatusNullable.closed:
        return CaseStatus.closed;
      default:
        return CaseStatus.open;
    }
  }
}
