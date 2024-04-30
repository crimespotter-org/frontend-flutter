import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/4data/mapProvider.dart';
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
    final caseProvider = Provider.of<CaseProvider>(context);
    final mapProvider = Provider.of<MapProvider>(context);
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
                bool isCase = caseProvider.cases.any((element) =>
                    element.longitude == currentLocation.longitude &&
                    element.latitude == currentLocation.latitude);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Visibility(
                          visible: !isCase,
                          child: GestureDetector(
                            onTap: () => {
                              widget.controller.removeMarker(geoPoint),
                              Navigator.pop(currentContext)
                            },
                            child: const Icon(Icons.delete),
                          ),
                        ),
                        Expanded(
                          child: isCase
                              ? buildCaseDetails(
                                  caseProvider.cases.firstWhere((element) =>
                                      element.longitude ==
                                          currentLocation.longitude &&
                                      element.latitude ==
                                          currentLocation.latitude),
                                )
                              : buildDetails(currentLocation),
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
            mapProvider.unloadMap(),
            if (isReady)
              await Future.delayed(
                Duration.zero,
                () async {
                  mapProvider.mapIsLoaded();
                  widget.controller.myLocation().then(
                        (value) => mapProvider.updateCurrentPosition(value),
                      );
                  for (var singleCase in caseProvider.filteredCases) {
                    if (mounted) {
                      await widget.controller.addMarker(
                        GeoPoint(
                            latitude: singleCase.latitude,
                            longitude: singleCase.longitude),
                        markerIcon:
                            buildMarker(singleCase.caseType, caseProvider),
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
                                          longitude:
                                              singleCase.longitude)] = value;
                                    },
                                  ),
                                }
                            },
                        },
                      );
                    }
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
        Visibility(
          visible: mapProvider.mapLoaded,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton(
                onPressed: () => {
                  widget.controller.myLocation().then(
                        (posistion) => {
                          mapProvider.updateCurrentPosition(posistion),
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
        ),
      ],
    );
  }

  MarkerIcon buildMarker(CaseType type, CaseProvider provider) {
    IconData icon;
    MaterialColor color;

    switch (type) {
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

  Widget buildDetails(GeoPoint location) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.markerMap[location]![0].locality!,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const Divider(
          thickness: 1,
        ),
        Text('Latitude: ${location.latitude}'),
        const SizedBox(height: 15),
        Text('Longitude: ${location.longitude}'),
      ],
    );
  }

  Widget buildCaseDetails(CaseDetails currentCase) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${currentCase.title} (${TDeviceUtil.convertCaseTypeToGerman(currentCase.caseType)})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        buildDivider(text: 'Status der Ermittlung'),
        buildRow(
          content: currentCase.status == CaseStatus.closed
              ? 'Ermittlungen sind bereits abgeschlossen'
              : 'Es wird bereits ermittel',
          widget: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentCase.status == CaseStatus.open
                    ? Colors.green
                    : Colors.red),
            width: 10,
            height: 10,
          ),
        ),
        buildDivider(text: 'Ort'),
        buildRow(
          content: '${currentCase.placeName} (Plz: ${currentCase.zipCode})',
          widget: const Icon(
            Icons.pin_drop,
            color: Colors.indigo,
          ),
        ),
        buildDivider(text: 'Zusammenfassung'),
        Text(
          currentCase.summary,
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
        ),
        ElevatedButton(
          onPressed: () => {
            Navigator.pushNamed(context, UIData.single_case,
                arguments: currentCase.id)
          },
          child: const Text('Zur Fallakte'),
        ),
      ],
    );
  }

  Widget buildRow(
      {Color iconColor = Colors.black,
      required String content,
      required Widget widget}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget,
        const SizedBox(
          width: 5,
        ),
        Text(
          content,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildDivider({required String text}) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider()),
        const SizedBox(
          width: 5,
          height: 50,
        ),
        Text(
          text,
          style: const TextStyle(color: Colors.blue),
        ),
        const SizedBox(
          width: 5,
          height: 50,
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
