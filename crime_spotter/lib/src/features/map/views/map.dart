import 'dart:io';

import 'package:crime_spotter/src/common/widget/widget/radioButton.dart';
import 'package:crime_spotter/src/common/widget/widget/searchBar.dart';
import 'package:crime_spotter/src/features/map/views/fleaFletMap.dart';
import 'package:crime_spotter/src/features/map/views/mapOption.dart';
import 'package:crime_spotter/src/features/map/views/mapSwipeCases.dart';
import 'package:crime_spotter/src/features/map/views/mapToggleButton.dart';
import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/mapProvider.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:crime_spotter/src/shared/4data/userdetailsProvider.dart';
import 'package:flutter/material.dart';
import 'package:crime_spotter/src/features/map/views/openStreetMap.dart';
import 'package:flutter_map/flutter_map.dart' as heat;
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //Die Marker auf der Map müssen erst gezeichnet werden, bevor navigiert werden darf
  bool mapLoaded = false;
  bool isHeatMap = false;
  bool showUpgradeRole = false;

  final ImagePicker _picker = ImagePicker();
  final heat.MapController heatController = heat.MapController();
  final Map<GeoPoint, List<Placemark>> markerMap = {};
  final Map<FilterType, String?> selectedFilter = {};
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
    heatController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MapProvider>(context);
    final userDetailsprovider = Provider.of<UserDetailsProvider>(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          TOpenStreetMap(controller: controller, markerMap: markerMap),
          Visibility(
            visible: provider.isHeatmap,
            child: OpenStreetMap(controller: heatController),
          ),
          Positioned(
            left: -MediaQuery.of(context).size.width /
                2, // Adjust the left position as needed
            top: -MediaQuery.of(context).size.height * 0.21,
            height: MediaQuery.of(context).size.height * 0.53,
            width: MediaQuery.of(context).size.width * 2,
            child: ClipOval(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/Backgroung.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: provider.mapLoaded,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  Center(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                          onPressed: () => {
                            buildUpgradeRole(userDetailsprovider),
                          },
                        ),
                        Text(
                          userDetailsprovider
                              .displayUserRole(userDetailsprovider.userRole),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TSearchBar(
                      controller: controller,
                      heatController: heatController,
                      markerMap: markerMap),
                  const SizedBox(
                    height: 10,
                  ),
                  TMapToggleButton(
                    controller: controller,
                    markers: markerMap,
                    selectedFilte: selectedFilter,
                  ),
                ],
              ),
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

  void buildUpgradeRole(UserDetailsProvider userDetailsprovider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final provider = Provider.of<UserDetailsProvider>(context);
        return AlertDialog(
          title: const Text('Benutzer bearbeiten'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Wählen Sie ein Profilbild für ${provider.currentUser.email}:'),
              const SizedBox(height: 10),
              userDetailsprovider.profilePictures.any((element) =>
                      element.userId == userDetailsprovider.currentUser.id)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.memory(userDetailsprovider.profilePictures
                          .where((element) =>
                              element.userId ==
                              userDetailsprovider.currentUser.id)
                          .first
                          .imageInBytes),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        "assets/placeholder.jpg",
                      ),
                    ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  child: const Text('Neues Bild auswählen'),
                  onPressed: () async => {
                    await _picker.pickImage(source: ImageSource.gallery).then(
                          (file) => {
                            if (file != null)
                              {
                                userDetailsprovider.updateProfilePicture(
                                    image: file)
                              }
                          },
                        ),
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              Text('Wählen Sie die Rolle für ${provider.currentUser.email}:'),
              const SizedBox(height: 10),
              Text(
                'Derzeitige Rolle: ${provider.displayUserRole(provider.userRole)}',
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: provider.displayUserRole(provider.userRole),
                onChanged: (newValue) {
                  setState(
                    () {
                      if (provider.userRole != UserRole.admin ||
                          provider.convertStringToUserRole(newValue ?? "") !=
                              UserRole.admin) {
                        provider.updateUserRole(
                          user: null,
                          role:
                              provider.convertStringToUserRole(newValue ?? ""),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Sie sind der einzige Admin und können sich nicht degradieren'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
                items: <String>[
                  provider.displayUserRole(UserRole.admin),
                  provider.displayUserRole(UserRole.crimefluencer),
                  provider.displayUserRole(UserRole.crimespotter)
                ].map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildChangeRole(UserRole role) {
    final provider = Provider.of<UserDetailsProvider>(context);
    return Visibility(
      visible: provider.userRole == role,
      child: ElevatedButton(
        child: Text(provider.displayUserRole(role)),
        onPressed: () => {
          if (provider.userRole != UserRole.admin || role != UserRole.admin)
            {
              provider.updateUserRole(user: null, role: role).then(
                    (successful) => {
                      if (successful)
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sie haben nun die Rolle $role'),
                              backgroundColor: Colors.green,
                            ),
                          ),
                          setState(
                            () {
                              showUpgradeRole = false;
                            },
                          )
                        }
                      else
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Beim Aktualisieren der Rolle ist ein Fehler aufgetreten.'),
                              backgroundColor: Colors.red,
                            ),
                          ),
                        },
                    },
                  ),
            }
          else
            {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Sie sind der einzige Admin und können sich nicht degradieren'),
                  backgroundColor: Colors.red,
                ),
              ),
            }
        },
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

    return Row(
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
