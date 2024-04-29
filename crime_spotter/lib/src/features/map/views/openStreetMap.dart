import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

class TOpenStreetMap extends StatefulWidget {
  final MapController controller;
  final Map<GeoPoint, List<Placemark>> markerMap;
  const TOpenStreetMap(
      {super.key, required this.controller, required this.markerMap});

  @override
  State<TOpenStreetMap> createState() => _TOpenStreetMapState();
}

class _TOpenStreetMapState extends State<TOpenStreetMap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        widget.controller.listenerMapSingleTapping.addListener(
          () async {
            GeoPoint? posistion =
                widget.controller.listenerMapSingleTapping.value;
            if (posistion != null) {
              await widget.controller.addMarker(
                posistion,
                markerIcon: const MarkerIcon(
                  icon: Icon(
                    Icons.pin_drop,
                    color: Colors.blue,
                    size: 48,
                  ),
                ),
              );
              placemarkFromCoordinates(posistion.latitude, posistion.longitude)
                  .then(
                (value) => {
                  if (value.isNotEmpty)
                    {
                      if (mounted)
                        {
                          setState(
                            () {
                              widget.markerMap[posistion] = value;
                            },
                          ),
                        }
                    },
                },
              );
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CaseProvider>(context);
    return Stack(
      children: [
        OSMFlutter(
          controller: widget.controller,
          mapIsLoading: const Center(
            child: CircularProgressIndicator(),
          ),
          onGeoPointClicked: (geoPoint) {
            GeoPoint currentLocation = GeoPoint(
                latitude: geoPoint.latitude, longitude: geoPoint.longitude);
            var currentContext = context;
            showModalBottomSheet(
              context: currentContext,
              builder: (currentContext) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => {
                            widget.controller.removeMarker(geoPoint),
                            Navigator.pop(currentContext)
                          },
                          child: const Icon(Icons.delete),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.markerMap[currentLocation]![0].locality!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const Divider(
                                thickness: 1,
                              ),
                              Text('Latitude: ${currentLocation.latitude}'),
                              const SizedBox(height: 15),
                              Text('Longitude: ${currentLocation.longitude}'),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(currentContext),
                          child: const Icon(Icons.clear),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
          onMapIsReady: (isReady) async => {
            if (isReady)
              await Future.delayed(
                Duration.zero,
                () async {
                  for (var singleCase in provider.filteredCases) {
                    await widget.controller.addMarker(
                      GeoPoint(
                          latitude: singleCase.latitude,
                          longitude: singleCase.longitude),
                      markerIcon: buildMarker(singleCase.caseType, provider),
                    );
                    placemarkFromCoordinates(
                            singleCase.latitude, singleCase.longitude)
                        .then(
                      (value) => {
                        if (value.isNotEmpty)
                          {
                            if (mounted)
                              {
                                setState(
                                  () {
                                    widget.markerMap[GeoPoint(
                                            latitude: singleCase.latitude,
                                            longitude: singleCase.longitude)] =
                                        value;
                                  },
                                ),
                              }
                          },
                      },
                    );
                  }
                },
              ),
          },
          osmOption: OSMOption(
            userTrackingOption: const UserTrackingOption(
              enableTracking: true,
              unFollowUser: false,
            ),
            zoomOption: const ZoomOption(
              initZoom: 15,
              minZoomLevel: 3,
              maxZoomLevel: 19,
              stepZoom: 1.0,
            ),
            userLocationMarker: UserLocationMaker(
              personMarker: const MarkerIcon(
                icon: Icon(
                  Icons.location_history_rounded,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              directionArrowMarker: const MarkerIcon(
                icon: Icon(
                  Icons.double_arrow,
                  size: 48,
                ),
              ),
            ),
            roadConfiguration: const RoadOption(
              roadColor: Colors.blueGrey,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FloatingActionButton(
              onPressed: () => {
                widget.controller.myLocation().then(
                      (posistion) => {
                        widget.controller.addMarker(
                          posistion,
                          markerIcon: const MarkerIcon(
                            icon: Icon(
                              Icons.pin_drop,
                              color: Colors.blue,
                              size: 48,
                            ),
                          ),
                        ),
                        placemarkFromCoordinates(
                                posistion.latitude, posistion.longitude)
                            .then(
                          (value) => {
                            if (value.isNotEmpty)
                              {
                                if (mounted)
                                  {
                                    setState(
                                      () {
                                        widget.markerMap[posistion] = value;
                                      },
                                    ),
                                  }
                              },
                          },
                        ),
                      },
                    ),
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ),
      ],
    );
  }

  MarkerIcon buildMarker(String type, CaseProvider provider) {
    IconData icon;
    MaterialColor color;
    var convertedType = provider.getCrimeTypeFromString(type);

    switch (convertedType) {
      case CaseType.murder:
        icon = Icons.directions_run;
        color = Colors.red;
        break;
      case CaseType.theft:
        icon = Icons.report;
        color = Colors.grey;
        break;
      case CaseType.robberyMurder:
        icon = Icons.local_atm;
        color = Colors.green;
        break;
      case CaseType.brawl:
        icon = Icons.groups;
        color = Colors.brown;
        break;
      case CaseType.rape:
        icon = Icons.pan_tool;
        color = Colors.purple;
        break;
      default:
        icon = Icons.pin_drop;
        color = Colors.blue;
        break;
    }
    return MarkerIcon(
      icon: Icon(
        icon,
        color: color,
        size: 48,
      ),
    );
  }
}
