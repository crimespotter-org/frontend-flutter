import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/model/DetailedAddress.dart';
import 'package:crime_spotter/src/shared/model/predictionResponse.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class FetchData {
  Future<PredictionResponse> searchLocation(String? locationName) async {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationName&types=(cities)&key=$googleMapsApiKey'));
    if (response.statusCode == 200) {
      var responseData = convert.jsonDecode(response.body);
      return PredictionResponse.fromJson(responseData);
    } else {
      throw Exception('Standorte konnten nicht geladen werden!');
    }
  }

  Future<ResultResponse> detailedAdress(String? locationName) async {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$locationName&key=$googleMapsApiKey'));
    if (response.statusCode == 200) {
      var responseData = convert.jsonDecode(response.body);
      return ResultResponse.fromJson(responseData);
    } else {
      throw Exception('Standorte konnten nicht geladen werden!');
    }
  }
}
