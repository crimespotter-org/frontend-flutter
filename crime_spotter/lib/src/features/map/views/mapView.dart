import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';

class TOpenStreetMap extends StatefulWidget {
  const TOpenStreetMap({super.key});

  @override
  State<TOpenStreetMap> createState() => _TOpenStreetMapState();
}

class _TOpenStreetMapState extends State<TOpenStreetMap> {
  Map<GeoPoint, List<Placemark>> markerMap = {};

  final MapController _controller = MapController.customLayer(
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _controller.listenerMapSingleTapping.addListener(
          () async {
            GeoPoint? posistion = _controller.listenerMapSingleTapping.value;
            if (posistion != null) {
              await _controller.addMarker(
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
                      setState(
                        () {
                          markerMap[posistion] = value;
                        },
                      ),
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OSMFlutter(
          controller: _controller,
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
                            _controller.removeMarker(geoPoint),
                            Navigator.pop(currentContext)
                          },
                          child: const Icon(Icons.delete),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                markerMap[currentLocation]![0].locality!,
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
                  await _controller.currentLocation();
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
                _controller.myLocation().then(
                      (posistion) => {
                        _controller.addMarker(
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
                                setState(
                                  () {
                                    markerMap[posistion] = value;
                                  },
                                ),
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
}
