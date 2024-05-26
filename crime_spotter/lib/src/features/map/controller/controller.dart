import 'package:crime_spotter/src/features/explore/1presentation/exploreArgs.dart';
import 'package:crime_spotter/src/features/map/views/map_option.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/supabase_const.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';

class ButtonController {
  static List<FloatingActionButton> itemsActionBar(
      BuildContext context,
      bool isAdmin,
      MapController mapController,
      Map<GeoPoint, List<Placemark>> markers,
      Map<FilterType, String?> selectedFilter) {
    List<FloatingActionButton> list = [];
    list.add(
      FloatingActionButton(
        heroTag: "signOut",
        backgroundColor: TColor.buttonColor2,
        onPressed: () {
          SupaBaseConst.supabase.auth.signOut();
          Navigator.pushReplacementNamed(context, UIData.logIn);
        },
        tooltip: "Ausloggen",
        child: const Icon(Icons.logout),
      ),
    );
    list.add(
      FloatingActionButton(
        heroTag: "explore",
        backgroundColor: TColor.buttonColor2,
        onPressed: () async {
          Navigator.pushNamed(
            context,
            UIData.explore,
            arguments: ExploreArgs(
                mapController: mapController,
                markers: markers,
                selectedFilter: selectedFilter),
          );
        },
        tooltip: "Entdecken",
        child: const Icon(Icons.explore),
      ),
    );

    if (isAdmin) {
      list.add(
        FloatingActionButton(
          heroTag: "changeRole",
          backgroundColor: TColor.buttonColor2,
          onPressed: () async {
            Navigator.pushNamed(context, UIData.settings);
          },
          tooltip: "Rollen verwalten",
          child: const Icon(Icons.manage_accounts),
        ),
      );
    }
    return list;
  }
}
