import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class FetchData {
  Future<List<LocationData>> searchLocation(String? locationName) async {
    //try {
    var response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$locationName&format=jsonv2'));
    if (response.statusCode == 200) {
      // Parsen der JSON-Daten und Erstellen einer Liste von LocationData-Instanzen
      List<dynamic> responseData = convert.jsonDecode(response.body);
      return responseData.map((json) => LocationData.fromJson(json)).toList();
    } else {
      // Falls die Anfrage fehlschlägt, wirft eine Exception
      throw Exception('Standorte konnten nicht geladen werden!');
    }
  }
}

class LocationData {
  final int placeId;
  final String licence;
  final String osmType;
  final int osmId;
  final String lat;
  final String lon;
  final String category;
  final String type;
  final int placeRank;
  final double importance;
  final String addressType;
  final String name;
  final String displayName;
  final List<String> boundingBox;

  LocationData({
    required this.placeId,
    required this.licence,
    required this.osmType,
    required this.osmId,
    required this.lat,
    required this.lon,
    required this.category,
    required this.type,
    required this.placeRank,
    required this.importance,
    required this.addressType,
    required this.name,
    required this.displayName,
    required this.boundingBox,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      placeId: json['place_id'],
      licence: json['licence'],
      osmType: json['osm_type'],
      osmId: json['osm_id'],
      lat: json['lat'],
      lon: json['lon'],
      category: json['category'],
      type: json['type'],
      placeRank: json['place_rank'],
      importance: json['importance'],
      addressType: json['addresstype'],
      name: json['name'],
      displayName: json['display_name'],
      boundingBox: List<String>.from(json['boundingbox']),
    );
  }
}
