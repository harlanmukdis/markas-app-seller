import 'package:flutter/material.dart';

import '../function/components.dart';
import '../function/get_responsive_font_size.dart';
import 'constant.dart';

abstract class AppStyles {
  // Bold Styles
  static TextStyle styleBold20(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: getResponsiveFontSize(context, fontSize: 20),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  // Semi-Bold Styles
  static TextStyle styleSemiBold24(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: getResponsiveFontSize(context, fontSize: 24),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleSemiBold18(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: getResponsiveFontSize(context, fontSize: 18),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleSemiBold16(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: getResponsiveFontSize(context, fontSize: 16),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleSemiBold14(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: getResponsiveFontSize(context, fontSize: 14),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleSemiBold12(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: getResponsiveFontSize(context, fontSize: 12),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  // Medium Styles
  static TextStyle styleMedium20(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: getResponsiveFontSize(context, fontSize: 20),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleMedium18(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: getResponsiveFontSize(context, fontSize: 18),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleMedium16(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: getResponsiveFontSize(context, fontSize: 16),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleMedium14(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: getResponsiveFontSize(context, fontSize: 14),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleMedium12(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: getResponsiveFontSize(context, fontSize: 12),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleMedium10(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: getResponsiveFontSize(context, fontSize: 10),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  // Regular Styles
  static TextStyle styleRegular20(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 20),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleRegular16(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 16),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleRegular14(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 14),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleRegular12(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 12),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleRegular11(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 11),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }

  static TextStyle styleRegular10(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 10),
      color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
    );
  }
}
