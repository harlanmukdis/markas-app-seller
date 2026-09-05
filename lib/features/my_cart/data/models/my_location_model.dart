import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationData {
  String? address;
  double? latitude;
  double? longitude;
  LatLng? latLng;

  LocationData({this.address, this.latitude, this.longitude, this.latLng});
}
