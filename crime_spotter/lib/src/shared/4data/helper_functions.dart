import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
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
      case 'opened':
      case 'Offen':
        return CaseStatus.open;
      case 'closed':
      case 'Abgeschlossen':
        return CaseStatus.closed;
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
      case CaseType.unknown:
      default:
        return 'Unbekannt';
    }
  }
}
