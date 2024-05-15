import 'dart:io';
import 'dart:typed_data';

import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:crime_spotter/src/shared/4data/helper_functions.dart';

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
  CaseType caseType;
  DateTime crimeDateTime;
  CaseStatus status;

  int upvotes = 0;
  int downvotes = 0;
  bool isNew = false;

  List<Media> images = [];
  List<Links> furtherLinks = [];
  List<Comment> comments = [];

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
      latitude: json['lat'].toDouble(),
      longitude: json['long'].toDouble(),
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      placeName: json['place_name'] ?? '',
      zipCode: json['zip_code'] ?? 0,
      caseType: TDeviceUtil.convertStringtoCaseType(json['case_type']) ??
          CaseType.murder, //unknown is not allowed in dropdown!!!
      crimeDateTime: DateTime.parse(json['crime_date_time']),
      status: TDeviceUtil.convertStringToCaseStatus(json['status']) ??
          CaseStatus.open, //unknown is not allowed in dropdown!!!
    );
  }

  CaseDetails.createNew()
      : id = null,
        title = "",
        summary = "",
        latitude = 1,
        longitude = 1,
        createdBy = '',
        createdAt = DateTime.now(),
        placeName = '',
        zipCode = 0,
        caseType = CaseType.murder,
        crimeDateTime = DateTime.now(),
        status = CaseStatus.open,
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

class Comment {
  String? id;
  String case_id;
  String user_id;
  String text;
  DateTime createdAt;

  Comment(
      {required this.id,
      required this.case_id,
      required this.user_id,
      required this.text,
      required this.createdAt});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        id: json['id'],
        case_id: json['case_id'],
        user_id: json['user_id'],
        text: json['text'],
        createdAt: DateTime.parse(json['created_at']));
  }
}
