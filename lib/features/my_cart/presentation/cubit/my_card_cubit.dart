import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/utils/app_images.dart';
import '../../data/models/my_card_model.dart';
import '../../data/models/my_location_model.dart';
import 'my_card_state.dart';

class MyCartCubit extends Cubit<MyCartState> {
  MyCartCubit() : super(MyCardInitial());

  static MyCartCubit get(context) => BlocProvider.of(context);

  List<MyCardModel> items = [
    MyCardModel(
        name: "Double Ruffle Knit",
        image: AppImages.cart3,
        price: 130.0,
        numOfPieces: 1,
        id: '1'),
    MyCardModel(
        name: "Triple Knit Sweater",
        image: AppImages.cart2,
        price: 150.0,
        numOfPieces: 2,
        id: '2'),
    MyCardModel(
        name: "Winter Coat",
        image: AppImages.cart1,
        price: 200.0,
        numOfPieces: 3,
        id: '4'),
  ];

  List<MyCardModel> myCardItems = [];

  void getItems() {
    myCardItems = items;
    emit(GetItems());
  }

  Future<void> removeItem(int index) async {
    myCardItems.removeAt(index);
    emit(ItemRemoved());
  }

  List<LocationData> myLocationsList = [
    LocationData(
        address: "120 Lane San Fransisco , East Falmouth MA",
        latitude: 37.7749,
        longitude: -122.4194,
        latLng: const LatLng(37.7749, -122.4194)),
    LocationData(
        address: "456 Market St",
        latitude: 37.7849,
        longitude: -122.4094,
        latLng: const LatLng(37.7849, -122.4094)),
    // LocationData(address: "789 Elm St", latitude: 37.7949, longitude: -122.3994, latLng: LatLng(37.7949, -122.3994)),
  ];
}
