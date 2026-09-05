import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../function/components.dart';
import 'constant.dart';

/// Light Theme
final ThemeData lightTheme = ThemeData(
  useMaterial3: false,
  primarySwatch: (isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor)
      .toMaterialColor(),
  scaffoldBackgroundColor: kWhiteColor,
  cardColor: kWhiteColor,
  fontFamily: kFontFamily,
  appBarTheme: _buildAppBarTheme(
    backgroundColor: kWhiteColor,
    statusBarIconBrightness: Brightness.dark,
  ),
  snackBarTheme: _buildSnackBarTheme(kWhiteColor),
);

/// Dark Theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: false,
  // cardColor: kDarkColor,
  primarySwatch: (isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor)
      .toMaterialColor(),

  scaffoldBackgroundColor: kDarkColor,
  fontFamily: kFontFamily,
  appBarTheme: _buildAppBarTheme(
    backgroundColor: kBlackColor,
    statusBarIconBrightness: Brightness.light,
  ),
  snackBarTheme: _buildSnackBarTheme(kBlackColor),
);

AppBarTheme _buildAppBarTheme({
  required Color backgroundColor,
  required Brightness statusBarIconBrightness,
}) {
  return AppBarTheme(
    backgroundColor: backgroundColor,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: statusBarIconBrightness,
    ),
  );
}

SnackBarThemeData _buildSnackBarTheme(Color contentColor) {
  return SnackBarThemeData(
    contentTextStyle: TextStyle(
      fontSize: 16,
      color: contentColor,
    ),
  );
}
