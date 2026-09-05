import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../core/function/components.dart';
import '../../core/utils/app_images.dart';
import '../../core/utils/app_routes.dart';
import '../../core/utils/constant.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  SplashViewState createState() => SplashViewState();
}

class SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late final AnimationController _colorController;
  late final AnimationController _slideController;
  late final AnimationController _roundController;

  late final Animation<Color?> _colorAnimation;
  late final Animation<Offset> _slideAnimationUp;
  late final Animation<Offset> _slideAnimationBot;
  late final Animation<double> _roundAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationControllers
    _colorController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _slideController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _roundController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    // Define color transition animation
    final targetColor = isAppDarkMode() ? kDarkColor : kWhiteColor;
    _colorAnimation = ColorTween(
            begin: isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
            end: targetColor)
        .animate(
      CurvedAnimation(parent: _colorController, curve: Curves.linear),
    );

    // Define slide animations
    _slideAnimationUp =
        Tween<Offset>(begin: const Offset(0, 4), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.linear),
    );
    _slideAnimationBot =
        Tween<Offset>(begin: const Offset(0, -4), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.linear),
    );

    // Define round animation
    _roundAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _roundController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _colorController.forward();
    _slideController.forward();
    _roundController.repeat(reverse: true); // Continuous rounding effect

    // Navigate to onboarding screen after a delay
    Timer(const Duration(seconds: 2), () {
      router.go(AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _colorController.dispose();
    _slideController.dispose();
    _roundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Container(
            color: _colorAnimation.value,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isAppDarkMode() ? 0.3 : 1.0,
                    child: AnimatedBuilder(
                      animation: _roundAnimation,
                      builder: (context, child) {
                        return ClipOval(
                          child: Transform.scale(
                            scale: 0.8 + (_roundAnimation.value * 0.2),
                            child: SvgPicture.asset(
                              AppImages.splash,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SlideTransition(
                        position: _slideAnimationBot,
                        child: SvgPicture.asset(
                          AppImages.logo,
                          height: 150,
                          width: 150,
                        ),
                      ),
                      24.sbh,
                      SlideTransition(
                        position: _slideAnimationUp,
                        child: SvgPicture.asset(
                          AppImages.Shopapay,
                          fit: BoxFit.scaleDown,
                          width: 200,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
