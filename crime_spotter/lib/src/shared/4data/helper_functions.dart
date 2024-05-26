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
}
