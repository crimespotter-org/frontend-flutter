import 'package:crime_spotter/src/features/explore/1presentation/structures.dart';
import 'package:crime_spotter/src/shared/4data/card_provider.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/4data/map_provider.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:crime_spotter/src/shared/constants/size.dart';
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
                    Icons.place,
                    color: TColor.defaultPinColor,
                    size: TSize.defaultPinSize,
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
                            child:
                                const Icon(Icons.delete, color: Colors.white),
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
                          child: const Icon(
                            Icons.clear,
                            color: Colors.white,
                          ),
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
                  widget.markerMap.addAll(
                    await mapProvider.rebuildInitialMarker(
                        controller: widget.controller,
                        caseProvider: caseProvider,
                        markers: widget.markerMap),
                  );
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
                backgroundColor: TColor.buttonColor,
                onPressed: () => {
                  widget.controller.myLocation().then(
                        (posistion) => {
                          mapProvider.updateCurrentPosition(posistion),
                          widget.controller.addMarker(
                            posistion,
                            markerIcon: const MarkerIcon(
                              icon: Icon(
                                Icons.person_pin_circle,
                                color: Colors.red,
                                size: TSize.defaultPinSize,
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
                          widget.controller.setZoom(zoomLevel: 15),
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

  Widget buildDetails(GeoPoint location) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.markerMap[location]![0].locality!,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Divider(
          thickness: 1,
        ),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              const TextSpan(
                text: 'Latitude: ',
                style: TextStyle(color: TColor.dividerColor),
              ),
              TextSpan(
                text: '${location.latitude}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              const TextSpan(
                text: 'Longitude: ',
                style: TextStyle(color: TColor.dividerColor),
              ),
              TextSpan(
                text: '${location.longitude}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
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
            color: Colors.white,
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
            Icons.person_pin_circle,
            color: TColor.defaultPinColor,
            size: TSize.defaultPinSize,
          ),
        ),
        buildDivider(text: 'Zusammenfassung'),
        Text(
          currentCase.summary,
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(TColor.buttonColor),
          ),
          onPressed: () => {
            Navigator.pushNamed(context, UIData.singleCase,
                arguments: currentCase.id)
          },
          child: const Text(
            'Zur Fallakte',
            style: TextStyle(color: Colors.white),
          ),
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
          style: const TextStyle(color: Colors.white),
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
          style: const TextStyle(color: TColor.dividerColor),
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
