import 'package:crime_spotter/src/features/map/views/map_option.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart';

class ExploreArgs {
  MapController mapController;
  Map<GeoPoint, List<Placemark>> markers;
  Map<FilterType, String?> selectedFilter;

  ExploreArgs({
    required this.mapController,
    required this.markers,
    required this.selectedFilter,
  });
}
