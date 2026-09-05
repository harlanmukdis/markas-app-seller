import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navy_wear/features/home/presentation/cubits/product_details_cubit/product_details_state.dart';

import '../../../../../core/function/components.dart';
import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/constant.dart';
import '../../../data/models/product_model.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit() : super(ProductDetailsInitial());

  static ProductDetailsCubit get(context) => BlocProvider.of(context);

  ProductsModels relatedProduct = ProductsModels(products: [
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
  ]);

  List<Color> availableColors = [
    isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
    const Color(0xffF76834),
    const Color(0xffBDBDBD),
    // LightColor.red,
    // LightColor.skyBlue,
  ];

  List<String> availableSizes = [
    'S',
    'M',
    'L',
  ];

  int currentIndex = 0;

  bool isFav = true;

  final List<String> imgList = [
    'https://via.placeholder.com/800x400.png?text=Slide+1',
    'https://via.placeholder.com/800x400.png?text=Slide+2',
    'https://via.placeholder.com/800x400.png?text=Slide+3',
  ];

  int currentIndicatorIndex = 0;

  final PageController pageController = PageController();

  void addNumber() {
    currentIndex = currentIndex + 1;
    emit(AddNumberState());
  }

  void minusNumber() {
    if (currentIndex > 0) {
      currentIndex = currentIndex - 1;
      emit(MinusNumberState());
    }
  }

  void addFav() {
    isFav = !isFav;
    emit(AddFavState());
  }

  void changeIndicator(index) async {
    pageController.jumpTo(index.toDouble()); // Update the active page

    emit(AddFavState());
  }
}
