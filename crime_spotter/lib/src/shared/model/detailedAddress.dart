class AddressResult {
  List<AddressComponent> addressComponents;
  Geometry geometry;
  String placeId;
  List<String> types;

  AddressResult({
    required this.addressComponents,
    required this.geometry,
    required this.placeId,
    required this.types,
  });

  factory AddressResult.fromJson(Map<String, dynamic> json) {
    return AddressResult(
      addressComponents: (json['address_components'] as List)
          .map((item) => AddressComponent.fromJson(item))
          .toList(),
      geometry: Geometry.fromJson(json['geometry']),
      placeId: json['place_id'],
      types: List<String>.from(json['types'] as List<dynamic>),
    );
  }
}

class ResultResponse {
  final List<AddressResult> predictions;
  final String status;

  ResultResponse({
    required this.predictions,
    required this.status,
  });

  factory ResultResponse.fromJson(Map<String, dynamic> json) {
    return ResultResponse(
      predictions: (json['results'] as List)
          .map((item) => AddressResult.fromJson(item))
          .toList(),
      status: json['status'],
    );
  }
}

class AddressComponent {
  String longName;
  String shortName;
  List<String> types;

  AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    return AddressComponent(
      longName: json['long_name'],
      shortName: json['short_name'],
      types: List<String>.from(json['types'] as List<dynamic>),
    );
  }

  static List<AddressComponent> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AddressComponent.fromJson(json)).toList();
  }
}

class Geometry {
  Location location;

  Geometry({
    required this.location,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location: Location.fromJson(json['location']),
    );
  }
}

class Location {
  double lat;
  double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
