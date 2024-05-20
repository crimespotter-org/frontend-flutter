import 'package:crime_spotter/src/features/map/4data/fetch_data.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/4data/map_provider.dart';
import 'package:crime_spotter/src/shared/model/prediction_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

import 'package:flutter_map/flutter_map.dart' as heat;
import 'package:geocoding/geocoding.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class TSearchBar extends StatefulWidget {
  final MapController controller;
  final heat.MapController heatController;
  final Map<GeoPoint, List<Placemark>> markerMap;
  const TSearchBar(
      {super.key,
      required this.controller,
      required this.heatController,
      required this.markerMap});

  @override
  State<TSearchBar> createState() => _TSearchBarState();
}

class _TSearchBarState extends State<TSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FetchData fetchData = FetchData();

  Future<PredictionResponse?> _runFilter(String value) async {
    PredictionResponse? result;

    if (value.isEmpty) {
      result = PredictionResponse(predictions: [], status: 'Nicht gefunden');
    } else {
      result = await fetchData.searchLocation(value);
    }

    return result;
  }

  void moveForHeatMap(GeoPoint position) {
    widget.heatController
        .move(LatLng(position.latitude, position.longitude), 15);
    Navigator.pop(context);
  }

  void moveForMainMap(GeoPoint position) {
    widget.controller.moveTo(position, animate: true);
    widget.controller.addMarker(
      position,
      markerIcon: const MarkerIcon(
        icon: Icon(
          Icons.pin_drop,
          color: Colors.blue,
          size: 48,
        ),
      ),
    );
    placemarkFromCoordinates(position.latitude, position.longitude).then(
      (value) => {
        if (value.isNotEmpty)
          {
            if (mounted)
              {
                setState(
                  () {
                    widget.markerMap[position] = value;
                  },
                ),
              }
          },
      },
    );
    Navigator.pop(context);
    widget.controller.setZoom(zoomLevel: 13);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapProvider>(context);
    return Container(
      height: 70,
      width: TDeviceUtil.getScreenWidth(context),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(60, 255, 255, 255),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        onSubmitted: (value) => {
          _runFilter(value).then(
            (prediction) {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  GeoPoint position;
                  return Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      image: DecorationImage(
                        image: AssetImage("assets/Backgroung.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.clear,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: prediction == null
                                  ? 0
                                  : prediction.predictions.length,
                              itemBuilder: (context, index) => GestureDetector(
                                onTap: () async => {
                                  {
                                    await fetchData
                                        .detailedAdress(prediction
                                            .predictions[index]
                                            .structuredFormatting
                                            .mainText)
                                        .then(
                                          (value) => {
                                            if (value.status != 'ZERO_RESULTS')
                                              {
                                                position = GeoPoint(
                                                    latitude: value
                                                        .predictions[0]
                                                        .geometry
                                                        .location
                                                        .lat,
                                                    longitude: value
                                                        .predictions[0]
                                                        .geometry
                                                        .location
                                                        .lng),
                                                if (provider.isHeatmap)
                                                  {
                                                    moveForHeatMap(position),
                                                  }
                                                else
                                                  {
                                                    moveForMainMap(position),
                                                  },
                                              },
                                          },
                                        ),
                                  },
                                },
                                child: Card(
                                  key: Key(prediction!.predictions[index]
                                      .structuredFormatting.mainText),
                                  elevation: 4,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: const DecorationImage(
                                        image:
                                            AssetImage("assets/LogIn-Card.png"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          prediction.predictions[index]
                                              .structuredFormatting.mainText,
                                          style: const TextStyle(
                                              fontSize: 24,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          'Land: ${prediction.predictions[index].structuredFormatting.secondaryText}',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        },
        decoration: const InputDecoration(
          labelText: 'Suche',
          labelStyle: TextStyle(color: Colors.white),
          suffixIcon: Icon(
            Iconsax.search_favorite,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
