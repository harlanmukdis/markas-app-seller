import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navy_wear/core/utils/extensions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/function/components.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../generated/l10n.dart';
import '../../../shared/widgets/custom_product_item.dart';
import '../cubits/home_page_cubit/home_page_cubit.dart';
import '../cubits/home_page_cubit/home_page_state.dart';
import 'widgets/custom_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomePageCubit()..getProducts(0),
      child: BlocBuilder<HomePageCubit, HomePageState>(
        builder: (BuildContext context, state) {
          var cubit = BlocProvider.of<HomePageCubit>(context);
          final l = S.of(context);

          return Scaffold(
            key: cubit.scaffoldKey,
            appBar: _buildHomeAppBar(l, context, cubit),
            drawer: const CustomDrawer(),
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(child: _searchSection(context)),
                  SliverToBoxAdapter(
                    child: _sliderSection(l, context, cubit: cubit),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverAppBarDelegate(
                      _categorySection(l, context, cubit: cubit),
                    ),
                  ),
                ];
              },
              body: _gridViewSection(cubit, context, l),
            ),
          );
        },
      ),
    );
  }

  Widget _categorySection(S l, BuildContext context,
      {required HomePageCubit cubit}) {
    return Container(
      color: isAppDarkMode() ? kDarkColor : kWhiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.sbh,
          Padding(
            padding: 24.psh,
            child: Row(
              children: [
                Text(l.newFashion, style: AppStyles.styleSemiBold18(context)),
                const Spacer(),
                TextButton(
                  onPressed: () => router.push(AppRoutes.newFashion),
                  child: Text(l.seeAll,
                      style: AppStyles.styleRegular14(context).copyWith(
                          color: isAppDarkMode()
                              ? kDarkPrimaryColor
                              : kLightPrimaryColor)),
                ),
              ],
            ),
          ),
          8.sbh,
          CategoryItems(cubit: cubit),
          10.sbh
        ],
      ),
    );
  }

  Widget _gridViewSection(HomePageCubit cubit, BuildContext context, S l) {
    return cubit.products.products.isEmpty
        ? Center(
            child: Text(
              l.notAvailable,
              style: AppStyles.styleMedium18(context),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            itemCount: cubit.products.products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (context.screenWidth / 250).round(),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: .8,
            ),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  router.push(
                    AppRoutes.productDetails,
                    extra: cubit.products.products[index].image,
                  );
                },
                child: CustomProductItem(
                  item: cubit.products.products[index],
                ),
              );
            },
          );
  }

  Widget _sliderSection(S l, BuildContext context,
      {required HomePageCubit cubit}) {
    return Column(
      children: [
        Padding(
          padding: 24.psh,
          child: Row(
            children: [
              Text(l.newOffers, style: AppStyles.styleSemiBold18(context)),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(l.seeAll,
                    style: AppStyles.styleRegular14(context).copyWith(
                        color: isAppDarkMode()
                            ? kDarkPrimaryColor
                            : kLightPrimaryColor)),
              ),
            ],
          ),
        ),
        8.sbh,
        CarouselSliderWidget(cubit: cubit),
      ],
    );
  }

  Padding _searchSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 20),
      child: CustomTextFormField(
        filled: true,
        hintText: S.of(context).search,
        prefix: SvgPicture.asset(
          AppImages.searchNormal,
          width: 24,
          height: 24,
          fit: BoxFit.scaleDown,
          colorFilter: ColorFilter.mode(
              isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
              BlendMode.srcIn),
        ),
        suffix: SvgPicture.asset(
          AppImages.filter,
          width: 24,
          height: 24,
          fit: BoxFit.scaleDown,
          colorFilter: ColorFilter.mode(
              isAppDarkMode() ? kDarkThirdColor : kLightThirdColor,
              BlendMode.srcIn),
        ),
      ),
    );
  }

  AppBar _buildHomeAppBar(S l, BuildContext context, HomePageCubit cubit) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.helloMahmoud, style: AppStyles.styleSemiBold14(context)),
          Text(
            l.letsExplore,
            style: AppStyles.styleRegular14(context).copyWith(
                color: isAppDarkMode()
                    ? kDarkThirdColor
                    : const Color(0xFF475467)),
          ),
        ],
      ),
      leadingWidth: 61,
      leading: Padding(
        padding: 16.ps,
        child: InkWell(
          onTap: () => cubit.scaffoldKey.currentState?.openDrawer(),
          child: Image.asset(
            AppImages.avatar,
            fit: BoxFit.scaleDown,
            width: 45,
            height: 45,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: 16.pe,
          child: InkWell(
            onTap: () => router.push(AppRoutes.notifications),
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xffE8E7F1)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppImages.notificationIcon,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
                      BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate(this.widget);

  final Widget widget;

  @override
  double get minExtent => 120;

  @override
  double get maxExtent => 120;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return widget;
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return true;
  }
}

class CarouselSliderWidget extends StatefulWidget {
  const CarouselSliderWidget({super.key, required this.cubit});

  final HomePageCubit cubit;

  @override
  State<CarouselSliderWidget> createState() => _CarouselSliderWidgetState();
}

class _CarouselSliderWidgetState extends State<CarouselSliderWidget> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: CarouselSlider.builder(
            carouselController: widget.cubit.carouselController,
            itemCount: widget.cubit.imageCover.length,
            options: CarouselOptions(
                aspectRatio: 300 / 100,
                autoPlay: true,
                viewportFraction: .7,
                scrollDirection: Axis.horizontal,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentPageIndex = index;
                  });
                }),
            itemBuilder: (context, index, realIndex) {
              return Padding(
                padding: 14.pe,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    widget.cubit.imageCover[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSmoothIndicator(
              onDotClicked: (index) {
                widget.cubit.carouselController?.animateToPage(index,
                    duration: const Duration(milliseconds: 350));
                setState(() {
                  currentPageIndex = index;
                });
              },
              duration: const Duration(milliseconds: 350),
              activeIndex: currentPageIndex,
              count: widget.cubit.imageCover.length,
              effect: ExpandingDotsEffect(
                spacing: 4,
                dotHeight: 8,
                dotWidth: 8,
                dotColor: const Color(0xffE0E0E0),
                activeDotColor:
                    isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CategoryItems extends StatelessWidget {
  const CategoryItems({
    super.key,
    required this.cubit,
  });

  final HomePageCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final List<String> item = [l.all, l.tShirt, l.shoes, l.blazers];

    return SizedBox(
      height: 35,
      child: ListView.builder(
        padding: 24.ps,
        scrollDirection: Axis.horizontal,
        itemCount: item.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: 10.pe,
            child: InkWell(
              onTap: () {
                cubit.changeIndex(index);
                cubit.getProducts(index);
                (context as Element).markNeedsBuild();
              },
              borderRadius: BorderRadius.circular(40),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: 35,
                decoration: BoxDecoration(
                  color: cubit.i == index
                      ? isAppDarkMode()
                          ? kDarkPrimaryColor
                          : kLightPrimaryColor
                      : isAppDarkMode()
                          ? kDarkColor
                          : kWhiteColor,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                      color: isAppDarkMode()
                          ? kDarkPrimaryColor
                          : kLightPrimaryColor),
                ),
                child: Center(
                  child: Text(
                    item[index],
                    style: AppStyles.styleMedium14(context).copyWith(
                      color: cubit.i == index
                          ? kWhiteColor
                          : (isAppDarkMode()
                              ? const Color(0xffDAE8FF)
                              : isAppDarkMode()
                                  ? kDarkPrimaryColor
                                  : kLightPrimaryColor),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
