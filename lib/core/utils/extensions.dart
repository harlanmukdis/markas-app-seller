import 'package:flutter/material.dart';

extension GapHelper on num {
  SizedBox get sbh => SizedBox(height: toDouble());

  SizedBox get sbw => SizedBox(width: toDouble());
}

extension MediaQueryHelper on BuildContext {
  double get screenHeight => MediaQuery.of(this).size.height;

  double get screenWidth => MediaQuery.of(this).size.width;
}

extension PaddingHelper on num {
  EdgeInsetsDirectional get pa => EdgeInsetsDirectional.all(toDouble());

  EdgeInsetsDirectional get ps => EdgeInsetsDirectional.only(start: toDouble());

  EdgeInsetsDirectional get pe => EdgeInsetsDirectional.only(end: toDouble());

  EdgeInsetsDirectional get pt => EdgeInsetsDirectional.only(top: toDouble());

  EdgeInsetsDirectional get pb =>
      EdgeInsetsDirectional.only(bottom: toDouble());

  EdgeInsetsDirectional get psh =>
      EdgeInsetsDirectional.symmetric(horizontal: toDouble());

  EdgeInsetsDirectional get psv =>
      EdgeInsetsDirectional.symmetric(vertical: toDouble());
}

extension MaterialColorExtension on Color {
  MaterialColor toMaterialColor() {
    return MaterialColor(
      value,
      <int, Color>{
        50: withOpacity(0.1),
        100: withOpacity(0.2),
        200: withOpacity(0.3),
        300: withOpacity(0.4),
        400: withOpacity(0.5),
        500: this, // Base color
        600: withOpacity(0.6),
        700: withOpacity(0.7),
        800: withOpacity(0.8),
        900: withOpacity(0.9),
      },
    );
  }
}
