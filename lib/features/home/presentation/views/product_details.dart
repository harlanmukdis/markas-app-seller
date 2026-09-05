import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navy_wear/core/utils/extensions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../generated/l10n.dart';
import '../../../shared/widgets/custom_product_item.dart';
import '../cubits/product_details_cubit/product_details_cubit.dart';
import '../cubits/product_details_cubit/product_details_state.dart';
import 'description_screen.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return BlocProvider(
      create: (context) => ProductDetailsCubit(),
      child: BlocConsumer<ProductDetailsCubit, ProductDetailsState>(
        builder: (BuildContext context, state) {
          var cubit = ProductDetailsCubit.get(context);
          return Scaffold(
            appBar: customAppBar(context, l.details,
                action: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      border: isAppDarkMode()
                          ? null
                          : Border.all(
                              color: const Color(0xffBDD8FF), width: .2),
                      shape: BoxShape.circle,
                      color: isAppDarkMode()
                          ? kBlackColor
                          : const Color(0xffF8F8F8),
                    ),
                    child: Icon(
                      size: 20,
                      Icons.share_outlined,
                      color: isAppDarkMode()
                          ? isAppDarkMode()
                              ? kDarkSecondColor
                              : kLightSecondColor
                          : isAppDarkMode()
                              ? kDarkSecondColor
                              : kLightSecondColor,
                    ),
                  ),
                )),
            body: SingleChildScrollView(
              padding: 24.psh,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 24,
                  ),
                  CarouselWithIndicator(
                    cubit: cubit,
                    imgList: [image, image, image],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text("Leaf Print Guipure Lace Butterfly",
                      style: AppStyles.styleMedium16(context)),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xffFBBF24),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        "4.4",
                        style: AppStyles.styleSemiBold16(context),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        "(130 ${l.reviews})",
                        style: AppStyles.styleRegular14(context).copyWith(
                            color: isAppDarkMode()
                                ? const Color(0xffD0D0D0)
                                : kLightThirdColor),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          router.push(AppRoutes.allReview);
                        },
                        child: Text(l.seeReview,
                            style: AppStyles.styleRegular12(context).copyWith(
                                color: isAppDarkMode()
                                    ? kDarkPrimaryColor
                                    : kLightPrimaryColor,
                                decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                  24.sbw,
                  Row(
                    children: [
                      Text(
                        '\$ 96.80',
                        style: AppStyles.styleSemiBold24(context),
                      ),
                      const SizedBox(width: 8),
                      Text('\$ 1000',
                          style: AppStyles.styleMedium10(context).copyWith(
                            color: const Color(0xffF76834),
                            decoration: TextDecoration.lineThrough,
                          )),
                      const Spacer(),
                      Container(
                        width: 27,
                        height: 27,
                        decoration: ShapeDecoration(
                          color:
                              isAppDarkMode() ? const Color(0xffFAFAFA) : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: isAppDarkMode()
                                ? BorderSide.none
                                : const BorderSide(
                                    width: 0.53,
                                    color: Color(0xFFC0C8C7),
                                  ),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.black,
                            size: 15,
                          ),
                          onPressed: () {
                            cubit.minusNumber();
                          },
                          padding: const EdgeInsets.all(0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "${cubit.currentIndex}",
                          style: AppStyles.styleSemiBold14(context).copyWith(
                              color: isAppDarkMode() ? kDarkSecondColor : null),
                        ),
                      ),
                      Container(
                        width: 27,
                        height: 27,
                        decoration: ShapeDecoration(
                          color: isAppDarkMode()
                              ? kDarkPrimaryColor
                              : kLightPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 19,
                          ),
                          onPressed: () {
                            cubit.addNumber();
                          },
                          padding: const EdgeInsets.all(0),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 28,
                  ),
                  Row(
                    children: [
                      Text(l.color, style: AppStyles.styleMedium16(context)),
                      8.sbw,
                      ColorsWidget(
                        availableColors: cubit.availableColors,
                      ),
                      const Expanded(
                        child: SizedBox(
                          width: 25,
                        ),
                      ),
                      Text(l.size, style: AppStyles.styleMedium16(context)),
                      10.sbw,
                      SizeWidget(
                        availableSizes: cubit.availableSizes,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            width: 1,
                            color: const Color(0xffDCDCDC).withOpacity(.5)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(l.seeDescription,
                                style: AppStyles.styleRegular14(context)
                                    .copyWith(
                                        color: isAppDarkMode()
                                            ? kDarkPrimaryColor
                                            : kLightPrimaryColor)),
                            const Spacer(),
                            const Icon(
                              color: kLightSecondColor,
                              Icons.arrow_forward_ios_sharp,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DescriptionScreen(),
                          ));
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Row(
                    children: [
                      Text(l.relatedProduct,
                          style: AppStyles.styleSemiBold18(context).copyWith()),
                      const Spacer(),
                      TextButton(
                        onPressed: () => router.push(AppRoutes.newFashion),
                        child: Text(
                          l.seeAll,
                          style: AppStyles.styleMedium16(context).copyWith(
                              color: isAppDarkMode()
                                  ? kDarkPrimaryColor
                                  : kLightPrimaryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cubit.relatedProduct.products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (context.screenWidth / 250).round(),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetails(image: image)),
                          );
                        },
                        child: CustomProductItem(
                          item: cubit.relatedProduct.products[index],
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
            bottomSheet: BottomAppBar(
              padding: 8.psv,
              shadowColor:
                  isAppDarkMode() ? kBlackColor.withOpacity(.07) : kBlackColor,
              color: isAppDarkMode() ? kDarkColor : kWhiteColor,
              elevation: 50,
              child: Padding(
                padding: 16.psh,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomButton(
                        elevation: 0,
                        backColor: Colors.transparent,
                        child: Text(l.addToCart,
                            style: AppStyles.styleSemiBold14(context)),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        child: Text(l.buyNow,
                            style: AppStyles.styleSemiBold14(context)
                                .copyWith(color: Colors.white)),
                        onPressed: () {},
                      ),
                    ),
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
}

class ColorsWidget extends StatefulWidget {
  final List<Color> availableColors;

  const ColorsWidget({super.key, required this.availableColors});

  @override
  ColorsWidgetState createState() => ColorsWidgetState();
}

class ColorsWidgetState extends State<ColorsWidget> {
  Color? selectedColor;

  @override
  void initState() {
    super.initState();
    // Set the first color as the default selected color
    if (widget.availableColors.isNotEmpty) {
      selectedColor = widget.availableColors.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _availableColor();
  }

  Widget _availableColor() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.start,
      children: widget.availableColors.map((color) {
        return _colorWidget(color);
      }).toList(),
    );
  }

  Widget _colorWidget(Color color) {
    final isSelected = selectedColor == color; // Check if the color is selected

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color; // Select the color on tap
        });
      },
      child: Container(
        padding:
            isSelected ? const EdgeInsets.all(3.5) : const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: const Color(0xffBDBDBD).withOpacity(.5), width: 1)
              : null,
        ),
        child: Container(
          width: 18, // Width of the circle
          height: 18, // Height of the circle
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color, // Use the original color without fading
          ),
        ),
      ),
    );
  }
}

class SizeWidget extends StatefulWidget {
  final List<String> availableSizes; // قائمة الأحجام

  const SizeWidget({super.key, required this.availableSizes});

  @override
  SizeWidgetState createState() => SizeWidgetState();
}

class SizeWidgetState extends State<SizeWidget> {
  String? selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.availableSizes.isNotEmpty) {
      selectedSize = widget.availableSizes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _availableSize();
  }

  Widget _availableSize() {
    return Wrap(
      spacing: 6,
      alignment: WrapAlignment.center,
      children: widget.availableSizes.map((size) {
        return _sizeWidget(size);
      }).toList(),
    );
  }

  Widget _sizeWidget(String size) {
    final isSelected = selectedSize == size; // Check if the size is selected

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSize = size; // Select the size on tap
        });
      },
      child: Container(
        padding: const EdgeInsets.only(left: 1), // Add padding only if selected
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Container(
          height: 24,
          width: 24,
          // padding: EdgeInsets.all(5), // Padding for text
          decoration: BoxDecoration(
            color: isSelected
                ? isAppDarkMode()
                    ? kDarkPrimaryColor
                    : kLightPrimaryColor
                : Colors.transparent,
            // Use a transparent color for the size representation
            borderRadius: BorderRadius.circular(50),
            border: isSelected
                ? null
                : Border.all(
                    color: const Color(0xffBDBDBD)
                        .withOpacity(.5)), // Rounded corners for the size box
          ),
          child: Center(
            child: Text(
              size, // Display size text
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isAppDarkMode()
                        ? kDarkPrimaryColor
                        : kLightPrimaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CarouselWithIndicator extends StatefulWidget {
  final ProductDetailsCubit cubit;
  final List<String> imgList;

  const CarouselWithIndicator({
    super.key,
    required this.cubit,
    required this.imgList,
  });

  @override
  CarouselWithIndicatorState createState() => CarouselWithIndicatorState();
}

class CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != widget.cubit.currentIndicatorIndex) {
        setState(() {
          widget.cubit.currentIndicatorIndex = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 327 / 202,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imgList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: kWhiteColor,
                  image: DecorationImage(
                    image: AssetImage(widget.imgList[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            right: isLanguageRTL() ? null : 0,
            left: isLanguageRTL() ? 0 : null,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: GestureDetector(
                onTap: widget.cubit.addFav,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: isAppDarkMode() ? kBlackColor : Colors.white,
                    shape: const OvalBorder(),
                    shadows: [
                      BoxShadow(
                        color: isAppDarkMode()
                            ? kBlackColor.withOpacity(.08)
                            : const Color(0x14000000),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.favorite_border_outlined,
                    size: 18,
                    color:
                        isAppDarkMode() ? kDarkSecondColor : kLightThirdColor,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: AnimatedSmoothIndicator(
              onDotClicked: (index) => _pageController.animateToPage(index,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut),
              activeIndex: widget.cubit.currentIndicatorIndex,
              count: widget.cubit.imgList.length,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                spacing: 4,
                activeDotColor: Color(0xff1D55F3),
                dotColor: Color(0xffFAFAFA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
