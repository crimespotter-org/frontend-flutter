import 'package:crime_spotter/src/features/map/controller/controller.dart';
import 'package:crime_spotter/src/features/map/views/map_option.dart';
import 'package:crime_spotter/src/shared/4data/userdetails_provider.dart';
import 'package:crime_spotter/src/shared/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:radial_button/widget/circle_floating_button.dart'
    as radial_button;

class TRadioButton extends StatefulWidget {
  final MapController mapController;
  final Map<GeoPoint, List<Placemark>> markers;
  final Map<FilterType, String?> selectedFilter;
  const TRadioButton(
      {super.key,
      required this.mapController,
      required this.markers,
      required this.selectedFilter});

  @override
  State<TRadioButton> createState() => _TRadioButtonState();
}

class _TRadioButtonState extends State<TRadioButton> {
  late List<FloatingActionButton> itemsActionBar;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserDetailsProvider>(context);

    itemsActionBar = ButtonController.itemsActionBar(
        context,
        provider.userRole == UserRole.admin,
        widget.mapController,
        widget.markers,
        widget.selectedFilter);
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: radial_button.CircleFloatingButton.floatingActionButton(
          items: itemsActionBar,
          duration: const Duration(milliseconds: 400),
          curveAnim: Curves.ease,
          useOpacity: true,
          color: TColor.buttonColor,
          icon: Icons.more_vert,
        ),
      ),
    );
  }
}
