import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/app_images.dart';
import '../../../data/models/product_model.dart';
import 'home_page_state.dart';

class HomePageCubit extends Cubit<HomePageState> {
  HomePageCubit() : super(HomePageInitial());

  static HomePageCubit get(context) => BlocProvider.of(context);
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController searchController = TextEditingController();

  CarouselSliderController? carouselController = CarouselSliderController();

  int i = 0;

  void changeIndex(int index) {
    i = index;
    emit(ChangeIndexState());
  }

  int reviewIndex = 0;

  void changeReviewIndex(int index) {
    reviewIndex = index;
    emit(ChangeReviewIndexState());
  }

  int currentIndex = 0;

  void homeToggleButton(int index) {
    currentIndex = index;
    emit(HomeToggleButton());
  }

  bool isDark = true;

  void isDarkMode() {
    isDark = !isDark;
    emit(HomeIsDarkMode());
  }

  List<String> imageCover = [
    AppImages.banner1,
    AppImages.banner2,
    AppImages.banner3,
  ];

  ProductsModels products = ProductsModels(products: []);

  void getProducts(int index) {
    if (index == 0) {
      products = ProductsModels(products: []);
      products.products.addAll(productsTShirt.products);
      products.products.addAll(productShoes.products);
      products.products.addAll(productBlazers.products);
    } else if (index == 1) {
      products = ProductsModels(products: []);
      products.products = productsTShirt.products;
    } else if (index == 2) {
      products = ProductsModels(products: []);
      products.products = productShoes.products;
    } else if (index == 3) {
      products = ProductsModels(products: []);
      products.products = productBlazers.products;
    }

    emit(HomePageGetProducts());
  }

  ProductsModels productsTShirt = ProductsModels(products: [
    ProductModel(
      id: '3',
      name: 'Minimalist Black T-Shirt',
      desc: 'Simple and sleek black T-shirt for everyday use.',
      price: 100.0,
      image: AppImages.product3,
      beforeDiscount: 150.0,
      discountPercentage: 33,
    ),
    ProductModel(
      id: '4',
      name: 'Striped White T-Shirt',
      desc: 'White T-shirt with a classic striped design.',
      price: 18.0,
      image: AppImages.product4,
      beforeDiscount: 20.0,
      discountPercentage: 10,
    ),
    ProductModel(
      id: '1',
      name: 'Classic Blue T-Shirt',
      desc:
          'Soft cotton T-shirt with a comfortable fit, perfect for casual wear.',
      price: 18.0,
      image: AppImages.product1,
      beforeDiscount: 20.0,
      discountPercentage: 1,
    ),
    ProductModel(
      id: '2',
      name: 'Sporty Red T-Shirt',
      desc: 'Lightweight T-shirt ideal for sports and outdoor activities.',
      price: 180.0,
      image: AppImages.product2,
      beforeDiscount: 200.0,
      discountPercentage: 10,
    ),
  ]);

  ProductsModels productBlazers = ProductsModels(products: []);

  ProductsModels productShoes = ProductsModels(products: [
    ProductModel(
      id: '5',
      name: 'Graphic T-Shirt',
      desc: 'Comfortable T-shirt featuring unique graphic artwork.',
      price: 180.0,
      image: AppImages.product5,
      beforeDiscount: 200.0,
      discountPercentage: 10,
    ),
    ProductModel(
      id: '6',
      name: 'Vintage Yellow T-Shirt',
      desc: 'Soft vintage-style T-shirt with a relaxed fit.',
      price: 50.0,
      image: AppImages.product6,
      beforeDiscount: 100.0,
      discountPercentage: 50,
    ),
    ProductModel(
      id: '2',
      name: 'Casual Sneakers',
      desc: 'Stylish sneakers perfect for everyday wear.',
      price: 18.0,
      image: AppImages.product9,
      beforeDiscount: 20.0,
      discountPercentage: 10,
    ),
    ProductModel(
      id: '3',
      name: 'Formal Leather Shoes',
      desc: 'Premium leather shoes designed for formal occasions.',
      price: 18.0,
      image: AppImages.product10,
      beforeDiscount: 20.0,
      discountPercentage: 10,
    ),
    ProductModel(
      id: '1',
      name: 'Running ',
      desc: 'Lightweight and durable running shoes for active lifestyles.',
      price: 18.0,
      image: AppImages.product8,
      beforeDiscount: 20.0,
      discountPercentage: 10,
    ),
    ProductModel(
      id: '1',
      name: 'Classic Black Blazer',
      desc: 'Elegant black blazer for formal and semi-formal events.',
      price: 50.0,
      image: AppImages.product7,
      beforeDiscount: 100.0,
      discountPercentage: 50,
    ),
    ProductModel(
      id: '5',
      name: 'Graphic T-Shirt',
      desc: 'Comfortable T-shirt featuring unique graphic artwork.',
      price: 180.0,
      image: AppImages.product5,
      beforeDiscount: 200.0,
      discountPercentage: 10,
    ),
  ]);
}
