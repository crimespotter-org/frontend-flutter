import 'dart:async';
import 'package:crime_spotter/src/features/LogIn/presentation/register.dart';
import 'package:crime_spotter/src/features/explore/1presentation/explore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/features/LogIn/presentation/login.dart';
import 'src/shared/4data/const.dart';

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nmijjbrgxttaatvjvegj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5taWpqYnJneHR0YWF0dmp2ZWdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTEwMjU4NjIsImV4cCI6MjAyNjYwMTg2Mn0.uSz4jgMEZ8P0ngtKEGbm5gjU9hgWBH3ALBdrUufBRYc',
    // authFlowType: AuthFlowType.pkce,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crime Spotter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Crime Spotter'),
      initialRoute: UIData.logIn,
      routes: <String, WidgetBuilder>{
        UIData.homeRoute: (BuildContext context) =>
            const MyHomePage(title: 'Crime Spotter'),
        UIData.logIn: (BuildContext context) => const LogIn(),
        UIData.register: (BuildContext context) => const Register(),
        UIData.explore: (BuildContext context) => const Explore(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const googlePlex = LatLng(37.4223, -122.0848);
  static const mountainView = LatLng(37.2861, -122.0839);

  late final StreamSubscription<AuthState> _authStateSubscription;
  final Completer<GoogleMapController> _controller = Completer();

  final double spaceBetweenButtons = 5;

  MapType _mapType = MapType.none;

  // Future<void> generatePolyLineFromPoints(
  //     List<LatLng> polylineCoordinates) async {
  //   const id = PolylineId('polyline');

  //   final polyline = Polyline(
  //     polylineId: id,
  //     color: Colors.blueAccent,
  //     points: polylineCoordinates,
  //     width: 5,
  //   );

  //   setState(() => polylines[id] = polyline);
  // }

  // Future<List<LatLng>> fetchPolyLinePoints() async {
  //   final polylinePoints = PolylinePoints();

  //   final result = await polylinePoints.getRouteBetweenCoordinates(
  //     googleMapsApiKey,
  //     PointLatLng(googlePlex.latitude, googlePlex.longitude),
  //     PointLatLng(mountainView.latitude, mountainView.longitude),
  //   );
  //   if (result.points.isNotEmpty) {
  //     return result.points
  //         .map((point) => LatLng(point.latitude, point.longitude))
  //         .toList();
  //   } else {
  //     debugPrint(result.errorMessage);
  //     return [];
  //   }
  // }

  // Future<void> fetchLocationUpdate() async {
  //   bool serviceEnabled;
  //   PermissionStatus permissionGranted;

  //   serviceEnabled = await locationController.serviceEnabled();
  //   if (!serviceEnabled) return;

  //   serviceEnabled = await locationController.requestService();

  //   permissionGranted = await locationController.hasPermission();
  //   if (permissionGranted == PermissionStatus.denied) {
  //     permissionGranted = await locationController.requestPermission();
  //     if (permissionGranted != PermissionStatus.granted) return;
  //   }

  //   locationController.onLocationChanged.listen(
  //     (currentLocation) {
  //       if (currentLocation.latitude != null &&
  //           currentLocation.longitude != null) {
  //         setState(
  //           () {
  //             currentPosition =
  //                 LatLng(currentLocation.latitude!, currentLocation.longitude!);
  //           },
  //         );
  //         print(currentPosition);
  //       }
  //     },
  //   );
  // }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<void> initializeMap() async {
    getUserCurrentLocation();
    // getCurrentLocation();
    // await fetchLocationUpdate();
    // final coordinates = await fetchPolyLinePoints();
    // generatePolyLineFromPoints(coordinates);
  }

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen(
      (data) {
        final session = data.session;

        if (session == null) {
          Navigator.of(context).pushReplacementNamed(UIData.logIn);
        }
      },
    );
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await initializeMap(),
    );
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  final List<Marker> _markers = <Marker>[
    // const Marker(
    //   markerId: MarkerId('sourceLocation'),
    //   icon: BitmapDescriptor.defaultMarker,
    //   position: googlePlex,
    // ),
    // const Marker(
    //   markerId: MarkerId('destinationLocation'),
    //   icon: BitmapDescriptor.defaultMarker,
    //   position: mountainView,
    // )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: googlePlex,
              zoom: 13,
            ),
            mapType: _mapType,
            markers: Set<Marker>.of(_markers),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            left: MediaQuery.of(context).size.width * 0.05,
            child: Container(
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  // IconButton(
                  //   splashColor: Colors.grey,
                  //   icon: const Icon(Icons.menu),
                  //   onPressed: () {},
                  // ),
                  Expanded(
                    child: TextField(
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.go,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 15),
                          hintText: "Search..."),
                    ),
                  ),
                  // const Padding(
                  //   padding: EdgeInsets.only(right: 8.0),
                  //   child: CircleAvatar(
                  //     backgroundColor: Colors.deepPurple,
                  //     child: Text('RD'),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          FloatingActionButton(
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
            onPressed: () async {
              getUserCurrentLocation().then(
                (value) async {
                  setState(
                    () {
                      _mapType = MapType.normal;
                    },
                  );
                },
              );
            },
            child: const Icon(Icons.location_on),
          ),
          SizedBox(height: spaceBetweenButtons),
          FloatingActionButton(
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
