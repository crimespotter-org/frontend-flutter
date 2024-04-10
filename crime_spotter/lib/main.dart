import 'dart:async';
import 'package:crime_spotter/src/features/LogIn/presentation/register.dart';
import 'package:crime_spotter/src/features/explore/1presentation/explore.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';

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
  final locationController = Location();

  LocationData? currentLocation;
  Map<PolylineId, Polyline> polylines = {};

  static const googlePlex = LatLng(37.4223, -122.0848);
  static const mountainView = LatLng(37.2861, -122.0839);

  late AnimationController controller;
  late Animation<double> animation;

  late final StreamSubscription<AuthState> _authStateSubscription;
  final Completer<GoogleMapController> _controller = Completer();

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

  Future<void> getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then((location) => currentLocation = location);

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen(
      (event) {
        currentLocation = event;

        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                event.latitude!,
                event.longitude!,
              ),
            ),
          ),
        );
        setState(() {});
      },
    );
  }

  Future<void> initializeMap() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: googlePlex,
          zoom: 13,
        ),
        markers: {
          // Marker(
          //   markerId: const MarkerId('currentLocation'),
          //   icon: BitmapDescriptor.defaultMarker,
          //   position: LatLng(
          //     currentLocation!.latitude!,
          //     currentLocation!.longitude!,
          //   ),
          // ),
          const Marker(
            markerId: MarkerId('sourceLocation'),
            icon: BitmapDescriptor.defaultMarker,
            position: googlePlex,
          ),
          const Marker(
            markerId: MarkerId('destinationLocation'),
            icon: BitmapDescriptor.defaultMarker,
            position: mountainView,
          )
        },
        //polylines: Set<Polyline>.of(polylines.values),
      ),
    );
  }
}
