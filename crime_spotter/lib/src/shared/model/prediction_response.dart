class LocationData {
  final String description;
  final List<MatchedSubstring> matchedSubstrings;
  final String placeId;
  final String reference;
  final StructuredFormatting structuredFormatting;
  final List<Term> terms;
  final List<String> types;

  LocationData({
    required this.description,
    required this.matchedSubstrings,
    required this.placeId,
    required this.reference,
    required this.structuredFormatting,
    required this.terms,
    required this.types,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      description: json['description'],
      matchedSubstrings: (json['matched_substrings'] as List)
          .map((item) => MatchedSubstring.fromJson(item))
          .toList(),
      placeId: json['place_id'],
      reference: json['reference'],
      structuredFormatting:
          StructuredFormatting.fromJson(json['structured_formatting']),
      terms:
          (json['terms'] as List).map((item) => Term.fromJson(item)).toList(),
      types: List<String>.from(json['types']),
    );
  }
}

class MatchedSubstring {
  final int length;
  final int offset;

  MatchedSubstring({
    required this.length,
    required this.offset,
  });

  factory MatchedSubstring.fromJson(Map<String, dynamic> json) {
    return MatchedSubstring(
      length: json['length'],
      offset: json['offset'],
    );
  }
}

class StructuredFormatting {
  final String mainText;
  final List<MatchedSubstring> mainTextMatchedSubstrings;
  final String secondaryText;

  StructuredFormatting({
    required this.mainText,
    required this.mainTextMatchedSubstrings,
    required this.secondaryText,
  });

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) {
    return StructuredFormatting(
      mainText: json['main_text'],
      mainTextMatchedSubstrings: (json['main_text_matched_substrings'] as List)
          .map((item) => MatchedSubstring.fromJson(item))
          .toList(),
      secondaryText: json['secondary_text'],
    );
  }
}

class Term {
  final int offset;
  final String value;

  Term({
    required this.offset,
    required this.value,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      offset: json['offset'],
      value: json['value'],
    );
  }
}

class PredictionResponse {
  final List<LocationData> predictions;
  final String status;

  PredictionResponse({
    required this.predictions,
    required this.status,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      predictions: (json['predictions'] as List)
          .map((item) => LocationData.fromJson(item))
          .toList(),
      status: json['status'],
    );
  }
}
