import 'package:crime_spotter/src/common/widget/widget/radioButton.dart';
import 'package:crime_spotter/src/common/widget/widget/searchBar.dart';
import 'package:crime_spotter/src/features/map/views/fleaFletMap.dart';
import 'package:crime_spotter/src/features/map/views/mapSwipeCases.dart';
import 'package:crime_spotter/src/features/map/views/mapToggleButton.dart';
import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/mapProvider.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:crime_spotter/src/features/map/views/openStreetMap.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool isHeatMap = false;

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
  bool mapLoaded =
      false; //Die Marker auf der Map müssen erst gezeichnet werden, bevor navigiert werden darf

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapProvider>(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          TOpenStreetMap(controller: controller, markerMap: markerMap),
          Visibility(
            visible: provider.isHeatmap,
            child: const OpenStreetMap(),
          ),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
            child: Column(
              children: [
                TSearchBar(controller: controller, markerMap: markerMap),
                const SizedBox(
                  height: 10,
                ),
                TMapToggleButton(controller: controller),
              ],
            ),
          ),
          Visibility(
            visible: provider.mapLoaded,
            child: const TRadioButton(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Visibility(
                    visible: provider.showSwipeableCases,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          buildCases(),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: buildButtons(),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCases() {
    final provider = Provider.of<CaseProvider>(context);
    final cases = provider.casesForVoting;

    return cases.isEmpty
        ? Center(
            child: ElevatedButton(
              child: const Text('Neu beginnen'),
              onPressed: () {
                final provider =
                    Provider.of<CaseProvider>(context, listen: false);
                provider.resetCases();
              },
            ),
          )
        : Stack(
            children: cases
                .map(
                  (image) => TMapSwipeCases(
                    image: image,
                    isFront: cases.last == image,
                  ),
                )
                .toList(),
          );
  }

  Widget buildButtons() {
    final provider = Provider.of<CaseProvider>(context);
    final status = provider.getStatus();
    final isLike = status == CaseVoting.like;
    final isDislike = status == CaseVoting.dislike;

    return
        // cases.isEmpty
        //     ? ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(16),
        //           ),
        //         ),
        //         child: const Text('Neu beginnen'),
        //         onPressed: () {
        //           final provider =
        //               Provider.of<CaseProvider>(context, listen: false);

        //           provider.resetCases();
        //         },
        //       )
        //     :
        Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            final provider = Provider.of<CaseProvider>(context, listen: false);

            provider.dislike();
          },
          style: ButtonStyle(
            overlayColor: getColor(Colors.white, Colors.red, isDislike),
            foregroundColor: getColor(Colors.white, Colors.red, isDislike),
            backgroundColor: getColor(Colors.white, Colors.red, isDislike),
          ),
          child: const Icon(
            Icons.clear,
            color: Colors.red,
            size: 20,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final provider = Provider.of<CaseProvider>(context, listen: false);
            provider.like();
          },
          style: ButtonStyle(
            overlayColor: getColor(Colors.white, Colors.green, isLike),
            foregroundColor: getColor(Colors.white, Colors.green, isLike),
            backgroundColor: getColor(Colors.white, Colors.green, isLike),
          ),
          child: const Icon(
            Icons.favorite,
            color: Colors.teal,
            size: 20,
          ),
        ),
      ],
    );
  }

  MaterialStateProperty<Color> getColor(
      Color color, Color colorPressed, bool force) {
    getColor(Set<MaterialState> states) {
      if (force || states.contains(MaterialState.pressed)) {
        return colorPressed;
      } else {
        return color;
      }
    }

    return MaterialStateProperty.resolveWith(getColor);
  }

  MaterialStateProperty<BorderSide> getBorder(
      Color color, Color colorPressed, bool force) {
    getBorder(Set<MaterialState> states) {
      if (force || states.contains(MaterialState.pressed)) {
        return const BorderSide(color: Colors.transparent);
      } else {
        return BorderSide(color: color, width: 3);
      }
    }

    return MaterialStateProperty.resolveWith(getBorder);
  }
}
