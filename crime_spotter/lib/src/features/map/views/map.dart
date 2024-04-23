import 'package:crime_spotter/src/common/widget/widget/radioButton.dart';
import 'package:crime_spotter/src/common/widget/widget/searchBar.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:crime_spotter/src/features/map/views/mapView.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (mounted && SupaBaseConst.supabase.auth.currentSession == null) {
          Navigator.popAndPushNamed(context, UIData.logIn);
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  final MapController controller = MapController.customLayer(
    customTile: CustomTile(
      sourceName: "opentopomap",
      tileExtension: ".png",
      minZoomLevel: 2,
      maxZoomLevel: 19,
      urlsServers: [
        TileURLs(
          url: "https://tile.openstreetmap.org/",
          subdomains: [],
        )
      ],
      tileSize: 256,
    ),
    initMapWithUserPosition: const UserTrackingOption(
      unFollowUser: false,
      enableTracking: true,
    ),
  );

  final Map<GeoPoint, List<Placemark>> markerMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          TOpenStreetMap(controller: controller, markerMap: markerMap),
          Positioned(
            left: -MediaQuery.of(context).size.width /
                2, // Adjust the left position as needed
            top: -MediaQuery.of(context).size.height * 0.21,
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width * 2,
            child: ClipOval(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                color: TColor.searchColor,
              ),
            ),
          ),
          TSearchBar(controller: controller, markerMap: markerMap),
          const TRadioButton(),
        ],
      ),
    );
  }
}
