// import 'package:Shopapay/core/utils/app_styles.dart';
// import 'package:Shopapay/core/utils/constant.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// import '../../../../core/function/components.dart';
// import '../../../../generated/l10n.dart';
//
// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});
//
//   @override
//   MapScreenState createState() => MapScreenState();
// }
//
// class MapScreenState extends State<MapScreen> {
//   GoogleMapController? mapController;
//   final LatLng _initialPosition =
//       const LatLng(30.0444, 31.2357); // Default location: Cairo
//   LatLng? _selectedLocation;
//   MapType _currentMapType = MapType.normal; // Default map type
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }
//
//   Future<void> _goToCurrentLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//       locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
//     );
//     LatLng currentLocation = LatLng(position.latitude, position.longitude);
//
//     mapController?.animateCamera(CameraUpdate.newLatLng(currentLocation));
//     setState(() {
//       _selectedLocation = currentLocation;
//     });
//   }
//
//   void _onMapTap(LatLng position) {
//     setState(() {
//       _selectedLocation = position; // Set the selected location
//     });
//   }
//
//   void _changeMapType() {
//     setState(() {
//       // Cycle through map types
//       if (_currentMapType == MapType.normal) {
//         _currentMapType = MapType.satellite;
//       } else if (_currentMapType == MapType.satellite) {
//         _currentMapType = MapType.hybrid;
//       } else {
//         _currentMapType = MapType.normal;
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final l = S.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: isAppDarkMode() ? Colors.transparent : null,
//         title: Text(l.mapLocation),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.my_location),
//             onPressed: _goToCurrentLocation,
//           ),
//           IconButton(
//             icon: const Icon(Icons.map),
//             onPressed: _changeMapType,
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: CameraPosition(
//               target: _initialPosition,
//               zoom: 10,
//             ),
//             onTap: _onMapTap,
//             mapType: _currentMapType,
//             // Set the map type
//             markers: _selectedLocation != null
//                 ? {
//                     Marker(
//                       markerId: const MarkerId("selectedLocation"),
//                       position: _selectedLocation!,
//                     ),
//                   }
//                 : {},
//           ),
//           Positioned(
//             bottom: 16,
//             left: 16,
//             child: FloatingActionButton.extended(
//               backgroundColor:
//                   isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
//               onPressed: () {
//                 // Here you can handle the selected location or process it
//                 if (_selectedLocation != null) {
//                   Navigator.pop(context,
//                       _selectedLocation); // Return the selected location
//                 }
//               },
//               label: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Text(l.done,
//                     style: AppStyles.styleSemiBold16(context)
//                         .copyWith(color: kWhiteColor)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
