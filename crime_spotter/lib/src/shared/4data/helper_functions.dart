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

  static CaseType? convertStringtoCaseType(String? crimeString) {
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
        return null;
    }
  }

  static CaseStatus? convertStringToCaseStatus(String? status) {
    switch (status) {
      case 'open':
      case 'Offen':
        return CaseStatus.open;
      case 'closed':
      case 'Geschlossen':
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

  static String? convertCaseTypeToString(CaseType type) {
    switch (type) {
      case CaseType.murder:
        return 'murder';
      case CaseType.theft:
        return 'theft';
      case CaseType.robberyMurder:
        return "robbery-murder";
      case CaseType.brawl:
        return 'brawl';
      case CaseType.rape:
        return 'rape';
      default:
        return null;
    }
  }

  static String convertCaseTypeToGerman(CaseType type) {
    switch (type) {
      case CaseType.murder:
        return 'Mord';
      case CaseType.theft:
        return 'Diebstahl';
      case CaseType.robberyMurder:
        return 'Tote bei Raub';
      case CaseType.brawl:
        return 'Schlägerei';
      case CaseType.rape:
        return 'Vergewaltigung';
      default:
        return 'Mord';
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
