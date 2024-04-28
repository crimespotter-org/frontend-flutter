import 'package:crime_spotter/src/features/map/4data/fetch_data.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:crime_spotter/src/shared/model/predictionResponse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:iconsax/iconsax.dart';

class TSearchBar extends StatefulWidget {
  final MapController controller;
  final Map<GeoPoint, List<Placemark>> markerMap;
  const TSearchBar(
      {super.key, required this.controller, required this.markerMap});

  @override
  State<TSearchBar> createState() => _TSearchBarState();
}

class _TSearchBarState extends State<TSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FetchData fetchData = FetchData();
  PredictionResponse? _fetchedLocations;

  void _runFilter(String value) async {
    PredictionResponse? result;

    if (value.isEmpty) {
      result = null;
    } else {
      result = await fetchData.searchLocation(value);
    }

    if (mounted) {
      setState(
        () {
          _fetchedLocations = result;
        },
      );
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      width: TDeviceUtil.getScreenWidth(context),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        onSubmitted: (value) => {
          _runFilter(value),
          showModalBottomSheet(
            backgroundColor: TColor.searchColor,
            context: context,
            builder: (context) {
              GeoPoint position;
              return Card(
                color: TColor.searchColor,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.clear),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _fetchedLocations == null
                              ? 0
                              : _fetchedLocations!.predictions.length,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () async => {
                              {
                                await fetchData
                                    .detailedAdress(_fetchedLocations!
                                        .predictions[index]
                                        .structuredFormatting
                                        .mainText)
                                    .then(
                                      (value) => {
                                        position = GeoPoint(
                                            latitude: value.predictions[index]
                                                .geometry.location.lat,
                                            longitude: value.predictions[index]
                                                .geometry.location.lng),
                                        widget.controller
                                            .moveTo(position, animate: true),
                                        widget.controller.addMarker(
                                          position,
                                          markerIcon: const MarkerIcon(
                                            icon: Icon(
                                              Icons.pin_drop,
                                              color: Colors.blue,
                                              size: 48,
                                            ),
                                          ),
                                        ),
                                        placemarkFromCoordinates(
                                                position.latitude,
                                                position.longitude)
                                            .then(
                                          (value) => {
                                            if (value.isNotEmpty)
                                              {
                                                if (mounted)
                                                  {
                                                    setState(
                                                      () {
                                                        widget.markerMap[
                                                            position] = value;
                                                      },
                                                    ),
                                                  }
                                              },
                                          },
                                        ),
                                        Navigator.pop(context),
                                        widget.controller
                                            .setZoom(zoomLevel: 13),
                                      },
                                    ),
                              },
                            },
                            child: Card(
                              key: Key(_fetchedLocations!.predictions[index]
                                  .structuredFormatting.mainText),
                              color: Colors.white,
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  Text(
                                    _fetchedLocations!.predictions[index]
                                        .structuredFormatting.mainText,
                                    style: const TextStyle(
                                        fontSize: 24, color: Colors.black),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Land: ${_fetchedLocations!.predictions[index].structuredFormatting.secondaryText}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
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
          ),
        },
        decoration: const InputDecoration(
          labelText: 'Suche',
          suffixIcon: Icon(
            Iconsax.search_favorite,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
