import 'dart:async';
import 'package:crime_spotter/src/features/map/4data/fetch_data.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:crime_spotter/src/shared/constants/size.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:radial_button/widget/circle_floating_button.dart'
    as radial_button;

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  final FetchData fetchData = FetchData();

  final double spaceBetweenButtons = 5;

  MapType _mapType = MapType.none;

  Future<Position> getUserCurrentLocation() async {
    try {
      //TODO: Auf die Permission subscriben, falls diese im Browser angepasst wurde
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Für diese App wird GPS benötigt!'),
            backgroundColor: Colors.red,
          ),
        );
        return Position(
            longitude: 0,
            latitude: 0,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0);
      }

      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (ex) {
      print(ex);
      return Position(
          longitude: 0,
          latitude: 0,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0);
    }
  }

  Position startposition = Position(
      latitude: 48.44548688211155,
      longitude: 8.696868994581505,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0);

  Future<void> initializeMap() async {
    await getUserCurrentLocation().then(
      (value) async {
        CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 14,
        );

        final GoogleMapController controller = await _controller.future;
        controller
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setState(
          () {
            _markers.add(
              Marker(
                markerId: const MarkerId("currentLocation2"),
                position: LatLng(value.latitude, value.longitude),
                infoWindow: const InfoWindow(
                  title: 'Mein Standort',
                ),
              ),
            );
          },
        );
        startposition = value;
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  List<LocationData> _fetchedLocations = <LocationData>[];
  @override
  void initState() {
    // fetchData
    //     .searchLocation('Trossingen')
    //     .then((value) => _fetchedLocations = _initialLocations = value);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (mounted && SupaBaseConst.supabase.auth.currentSession == null) {
          Navigator.popAndPushNamed(context, UIData.logIn);
        } else {
          await initializeMap();
        }
      },
    );
  }

  @override
  void dispose() {
    _markers.clear();
    _searchController.dispose();
    super.dispose();
  }

  final List<Marker> _markers = <Marker>[];

  void _runFilter(String value) async {
    List<LocationData> result = [];

    if (value.isEmpty) {
      result = [];
    } else {
      result = await fetchData.searchLocation(value);
    }

    setState(
      () {
        _fetchedLocations = result;
        _fetchedLocations = TDeviceUtil.removeDuplicates(_fetchedLocations);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var itemsActionBar = [
      FloatingActionButton(
        heroTag: "signOut",
        backgroundColor: Colors.greenAccent,
        onPressed: () {
          SupaBaseConst.supabase.auth.signOut();
          Navigator.pushReplacementNamed(context, UIData.logIn);
        },
        tooltip: "Ausloggen",
        child: const Icon(Icons.add),
      ),
      FloatingActionButton(
        heroTag: "explore",
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          Navigator.pushReplacementNamed(context, UIData.explore);
        },
        tooltip: "Entdecken",
        child: const Icon(Icons.explore),
      ),
      FloatingActionButton(
        heroTag: "settings",
        backgroundColor: Colors.grey,
        onPressed: () async {
          Navigator.pushReplacementNamed(context, UIData.settings);
        },
        tooltip: "Einstellungen",
        child: const Icon(Icons.settings),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(startposition.latitude, startposition.longitude),
              zoom: 13,
            ),
            mapType: _mapType,
            markers: Set<Marker>.of(_markers),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            zoomControlsEnabled: false,
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            left: MediaQuery.of(context).size.width * 0.05,
            child: Container(
              height: 200,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: TSize.defaultSpace),
                      child: Container(
                        width: TDeviceUtil.getScreenWidth(context),
                        padding: const EdgeInsets.all(TSize.md),
                        decoration: BoxDecoration(
                            color: Colors.white, ///////////////////
                            borderRadius:
                                BorderRadius.circular(15), //////////////
                            border: Border.all(color: Colors.grey)),
                        child: TextField(
                          onSubmitted: (value) => _runFilter(value),
                          decoration: const InputDecoration(
                            labelText: 'Suche',
                            suffixIcon: Icon(
                              Iconsax.search_favorite,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _fetchedLocations.length,
                        itemBuilder: (context, index) => Card(
                          key: Key(_fetchedLocations[index].addressType),
                          color: Colors.blue,
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            leading: Text(
                              _fetchedLocations[index].name,
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.white),
                            ),
                            subtitle: Text(
                              'Lat: ${_fetchedLocations[index].lat}, Lon: ${_fetchedLocations[index].lon}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Radial Button
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: radial_button.CircleFloatingButton.floatingActionButton(
                items: itemsActionBar,
                color: Colors.orangeAccent,
                icon: Icons.no_food,
                duration: const Duration(milliseconds: 400),
                curveAnim: Curves.ease,
                useOpacity:
                    true, // Add this parameter if required by CircleFloatingButton implementation
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          FloatingActionButton(
            heroTag: "currentLocation",
            onPressed: () async {
              getUserCurrentLocation().then(
                (value) async {
                  _markers.add(
                    Marker(
                      markerId: const MarkerId("currentLocation"),
                      position: LatLng(value.latitude, value.longitude),
                      infoWindow: const InfoWindow(
                        title: 'Mein Standort',
                      ),
                    ),
                  );

                  CameraPosition cameraPosition = CameraPosition(
                    target: LatLng(value.latitude, value.longitude),
                    zoom: 14,
                  );

                  final GoogleMapController controller =
                      await _controller.future;
                  controller.animateCamera(
                      CameraUpdate.newCameraPosition(cameraPosition));
                  setState(
                    () {},
                  );
                },
              );
            },
            child: const Icon(Icons.local_activity),
          ),
          SizedBox(height: spaceBetweenButtons),
          FloatingActionButton(
            heroTag: "mapNormal",
            onPressed: () async {
              setState(
                () {
                  _mapType = MapType.normal;
                },
              );
            },
            child: const Icon(Icons.location_on),
          ),
          SizedBox(height: spaceBetweenButtons),
          FloatingActionButton(
            heroTag: "mapHybrid",
            onPressed: () async {
              setState(
                () {
                  _mapType = MapType.hybrid;
                },
              );
            },
            child: const Icon(Icons.satellite_alt),
          ),
          SizedBox(height: spaceBetweenButtons),
          FloatingActionButton(
            heroTag: "mapTerrain",
            onPressed: () async {
              setState(
                () {
                  _mapType = MapType.terrain;
                },
              );
            },
            child: const Icon(Icons.terrain),
          ),
        ],
      ),
    );
  }
}

class TSearchContainer extends StatelessWidget {
  const TSearchContainer({
    super.key,
    required this.text,
    this.icon = Iconsax.search_normal,
  });

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final dark = TDeviceUtil.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSize.defaultSpace),
      child: Container(
        width: TDeviceUtil.getScreenWidth(context),
        padding: const EdgeInsets.all(TSize.md),
        decoration: BoxDecoration(
            color: dark ? Colors.black : Colors.white, ///////////////////
            borderRadius: BorderRadius.circular(15), //////////////
            border: Border.all(color: Colors.grey)),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey,
            ), //////////////////////
            const SizedBox(width: TSize.spaceBtwItems),
            Text('Suche nach einer Stadt',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
