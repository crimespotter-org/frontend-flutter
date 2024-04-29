import 'dart:io';
import 'dart:typed_data';

class CaseDetails {
  String? id;
  String title;
  String summary;
  double latitude;
  double longitude;
  String createdBy;
  DateTime createdAt;
  String placeName;
  int zipCode;
  String caseType;
  DateTime crimeDateTime;
  String status;

  bool isNew = false;

  List<Media> images = [];
  List<Links> furtherLinks = [];

  CaseDetails({
    required this.id,
    required this.title,
    required this.summary,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.createdAt,
    required this.placeName,
    required this.zipCode,
    required this.caseType,
    required this.crimeDateTime,
    required this.status,
  });

  factory CaseDetails.fromJson(Map<String, dynamic> json) {
    return CaseDetails(
      id: json['id'],
      title: json['title'],
      summary: json['summary'] ?? '',
      latitude: json['lat'],
      longitude: json['long'],
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      placeName: json['place_name'] ?? '',
      zipCode: json['zip_code'] ?? 0,
      caseType: json['case_type'] ?? '',
      crimeDateTime: DateTime.parse(json['crime_date_time']),
      status: json['status'] ?? '',
    );
  }

  CaseDetails.createNew()
      : id = null,
        title = "",
        summary = "",
        latitude = 0,
        longitude = 0,
        createdBy = '',
        createdAt = DateTime.now(),
        placeName = '',
        zipCode = 0,
        caseType = "murder",
        crimeDateTime = DateTime.now(),
        status = '',
        isNew = true;
}

class Media {
  Uint8List image;
  String name;
  Media({required this.image, required this.name});
}

class MediaToAdd {
  final String name;
  final File file;

  MediaToAdd(this.name, this.file);
}

class Links {
  String url;
  String type;
  String? id;
  DateTime createdAt;

  bool updated = false;
  bool isNew = false;
  bool delete = false;

  Links(
      {required this.type,
      required this.url,
      required this.id,
      required this.createdAt,
      this.updated = false});

  Links.createNew()
      : type = 'newspaper',
        url = '',
        createdAt = DateTime.now(),
        isNew = true,
        id = null;

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
        id: json['link_id'],
        url: json['url'],
        type: json['link_type'] ?? 'newspaper',
        createdAt: DateTime.parse(json['link_created_at']));
  }

  Links copyWith({String? type, String? url, String? id, DateTime? createdAt}) {
    return Links(
      id: id ?? this.id,
      url: url ?? this.url,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updated: true,
    );
  }
}
