import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../generated/l10n.dart';
import '../../data/models/my_location_model.dart';
import '../cubit/my_card_cubit.dart';
import '../cubit/my_card_state.dart';
import 'widgets/checkout_details.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  LatLng? selectedLocation;
  GoogleMapController? mapController;
  String? address;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return BlocProvider(
      create: (context) => MyCartCubit(),
      child: BlocConsumer<MyCartCubit, MyCartState>(
        builder: (BuildContext context, state) {
          var cubit = BlocProvider.of<MyCartCubit>(context);
          return Scaffold(
            appBar: customAppBar(context, l.checkout),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    8.sbh,
                    Text(
                      l.deliveryAddress,
                      style: AppStyles.styleSemiBold16(context),
                    ),
                    const SizedBox(height: 24),
                    _buildAddressSection(cubit, l),
                    const SizedBox(height: 24),
                    _buildPaymentMethod(l),
                    24.sbh,
                    const CheckoutDetails(),
                  ],
                ),
              ),
            ),
          );
        },
        listener: (BuildContext context, state) {},
      ),
    );
  }

  Future<LatLng?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      Position position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<String> _getAddressFromLatLng(LatLng latLng, S l) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      Placemark place = placemarks[0];
      return place.street ?? l.unknownLocation;
    } catch (_) {
      return "Error getting address";
    }
  }

  void _loadCurrentLocation() async {
    final l = S.of(context);
    LatLng? location = await _getCurrentLocation();
    if (location != null) {
      String fetchedAddress = await _getAddressFromLatLng(location, l);
      setState(() {
        selectedLocation = location;
        address = fetchedAddress;
      });
    } else {
      setState(() {
        address = l.unableToGetCurrentLocation;
      });
    }
  }

  // Future<void> _updateAddress(MyCartCubit cubit, S l) async {
  //   final selectedLocation = await Navigator.push<LatLng>(
  //     context,
  //     MaterialPageRoute(builder: (context) => const MapScreen()),
  //   );
  //
  //   if (selectedLocation != null) {
  //     String newAddress = await _getAddressFromLatLng(selectedLocation, l);
  //     cubit.myLocationsList = [
  //       LocationData(
  //         address: newAddress,
  //         latitude: selectedLocation.latitude,
  //         longitude: selectedLocation.longitude,
  //         latLng: selectedLocation,
  //       )
  //     ];
  //     setState(() {});
  //   }
  // }

  Widget _buildAddressSection(MyCartCubit cubit, S l) {
    if (cubit.myLocationsList.isEmpty) {
      return Center(
        child: GestureDetector(
          // onTap: () => _updateAddress(cubit, l),
          child: Text(
            l.addAddress,
            style: const TextStyle(color: Colors.blue, fontSize: 16),
          ),
        ),
      );
    } else {
      final location = cubit.myLocationsList.first;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  location.address ?? l.loading,
                  style: AppStyles.styleMedium14(context).copyWith(
                      color: isAppDarkMode() ? kDarkThirdColor : null),
                ),
              ),
              16.sbw,
              InkWell(
                // onTap: () => _updateAddress(cubit, l),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xffBDD8FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: isAppDarkMode()
                        ? kDarkPrimaryColor
                        : kLightPrimaryColor,
                    size: 20,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          _buildGoogleMap(location),
          const SizedBox(height: 16),
          GestureDetector(
            // onTap: () => _updateAddress(cubit, l),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add,
                    color: isAppDarkMode()
                        ? kDarkPrimaryColor
                        : kLightPrimaryColor),
                const SizedBox(width: 8),
                Text(l.addNewAddress,
                    style: TextStyle(
                        color: isAppDarkMode()
                            ? kDarkPrimaryColor
                            : kLightPrimaryColor,
                        fontSize: 16)),
              ],
            ),
          )
        ],
      );
    }
  }

  Widget _buildPaymentMethod(S l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.paymentMethod,
          style: AppStyles.styleSemiBold16(context).copyWith(
              color:
                  isAppDarkMode() ? kDarkSecondColor : const Color(0xff071731)),
        ),
        8.sbh,
        Text(
          l.listOfAllCreditCardsYouSaved,
          style: AppStyles.styleMedium14(context).copyWith(
              color:
                  isAppDarkMode() ? const Color(0xffD0D0D0) : kLightThirdColor),
        ),
        24.sbh,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 46,
                height: 67,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 46,
                        height: 67,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 1, color: Color(0xFFE9E8EB)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 5,
                      top: 7,
                      child: Container(
                        width: 36,
                        height: 53,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(41.50),
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.add,
                        color: isAppDarkMode()
                            ? kDarkPrimaryColor
                            : kLightPrimaryColor),
                  ],
                ),
              ),
              14.sbw,
              Container(
                padding: 12.pt,
                width: 80,
                height: 67,
                decoration: BoxDecoration(
                  color: isAppDarkMode() ? kWhiteColor : null,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isAppDarkMode()
                          ? kDarkPrimaryColor
                          : kLightPrimaryColor,
                      width: 1),
                ),
                child: SvgPicture.asset(
                  AppImages.paymentIcon1,
                  fit: BoxFit.cover,
                ),
              ),
              14.sbw,
              Container(
                width: 80,
                height: 67,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xffE9E8EB), width: 1),
                ),
                child: Center(child: SvgPicture.asset(AppImages.paymentIcon2)),
              ),
              14.sbw,
              Container(
                width: 80,
                height: 67,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xffE9E8EB), width: 1),
                ),
                child: Center(
                    child: SvgPicture.asset(
                  AppImages.paymentIcon3,
                  colorFilter: isAppDarkMode()
                      ? ColorFilter.mode(
                          isAppDarkMode()
                              ? kDarkSecondColor
                              : kLightSecondColor,
                          BlendMode.srcIn)
                      : null,
                )),
              ),
            ],
          ),
        ),
        24.sbh,
        Row(
          children: [
            Expanded(
              child: Text(l.addDeliveryInstruction,
                  style: AppStyles.styleSemiBold16(context)),
            ),
            InkWell(
              onTap: () {},
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xffBDD8FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color:
                      isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
                  size: 20,
                ),
              ),
            )
          ],
        ),
        24.sbh,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xffBDBDBD), width: 1),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppImages.deliveryIcon1,
                    fit: BoxFit.cover,
                    width: 20,
                  ),
                ),
              ),
              12.sbw,
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffBDBDBD), width: 1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppImages.deliveryIcon2,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              12.sbw,
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffBDBDBD), width: 1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppImages.deliveryIcon3,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              12.sbw,
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:
                      isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: kWhiteColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleMap(LocationData location) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          AppImages.map,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
    // GoogleMap(
    //   onMapCreated: (controller) {
    //     mapController = controller;
    //   },
    //   initialCameraPosition: CameraPosition(
    //     target: location.latLng ?? const LatLng(0, 0),
    //     zoom: 15,
    //   ),
    //   markers: {
    //     Marker(
    //       markerId: const MarkerId("currentLocation"),
    //       position: location.latLng ?? const LatLng(0, 0),
    //     ),
    //   },
    // ),
  }
}
