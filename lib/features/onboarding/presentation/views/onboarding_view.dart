import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/function/components.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../generated/l10n.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<String> images = [
    AppImages.onboarding1,
    AppImages.onboarding2,
    AppImages.onboarding3
  ];

  @override
  Widget build(BuildContext context) {
    final local = S.of(context);
    return Scaffold(
      backgroundColor: isAppDarkMode() ? kDarkColor : const Color(0xffFAFAFA),
      body: Stack(
        children: [
          // Background Images
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) => Image.asset(images[index]),
          ),
          // Bottom Content
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                decoration: BoxDecoration(
                  color: isAppDarkMode() ? kDarkColor : kWhiteColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: _buildOnboardingContent(context, local),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingContent(BuildContext context, S local) {
    return Column(
      children: [
        Text(
          _getTitle(_currentPage, local),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.styleMedium20(context),
        ),
        8.sbh,
        Text(
          _getSubTitle(_currentPage, local),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.styleRegular14(context).copyWith(
              color: isAppDarkMode() ? kDarkThirdColor : kLightThirdColor),
        ),
        24.sbh,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Opacity(
              opacity: 0,
              child: TextButton(
                onPressed: null,
                child: SizedBox(),
              ),
            ),
            AnimatedSmoothIndicator(
              onDotClicked: (index) => _controller.jumpToPage(index),
              activeIndex: _currentPage,
              count: images.length,
              effect: CustomizableEffect(
                activeDotDecoration: DotDecoration(
                  width: 40,
                  height: 8,
                  color:
                      isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                dotDecoration: DotDecoration(
                  width: 8,
                  height: 8,
                  color: const Color(0xff246BFD).withOpacity(.16),
                  borderRadius: BorderRadius.circular(500),
                ),
              ),
            ),
            Opacity(
              opacity: !(_currentPage == images.length - 1) ? 1 : 0,
              child: TextButton(
                onPressed: () => router.go(AppRoutes.welcome),
                child: Text(
                  local.skip,
                  style: AppStyles.styleRegular12(context).copyWith(
                      color: isAppDarkMode()
                          ? kDarkPrimaryColor
                          : kLightPrimaryColor),
                ),
              ),
            ),
          ],
        ),
        32.sbh,
        CustomButton(
          onPressed: () {
            if (_currentPage < images.length - 1) {
              _controller.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeIn,
              );
            } else {
              router.go(AppRoutes.welcome);
            }
          },
          child: Text(
            _currentPage == images.length - 1 ? local.getStarted : local.next,
            style:
                AppStyles.styleMedium16(context).copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  String _getTitle(int index, S local) {
    switch (index) {
      case 0:
        return local.discoverPossibilitiesTitle;
      case 1:
        return local.effortlessShoppingTitle;
      case 2:
        return local.stayAheadTitle;
      default:
        return '';
    }
  }

  String _getSubTitle(int index, S local) {
    switch (index) {
      case 0:
        return local.discoverPossibilitiesSubtitle;
      case 1:
        return local.effortlessShoppingSubtitle;
      case 2:
        return local.stayAheadSubtitle;
      default:
        return '';
    }
  }
}
