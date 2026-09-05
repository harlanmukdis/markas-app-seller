import 'package:flutter/material.dart';

import '../function/components.dart';
import '../utils/constant.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height,
    this.backColor,
    this.txtColor,
    this.elevation,
    this.width,
    this.padding,
    this.borderColor = Colors.transparent,
    this.borderRadius,
  });

  final void Function()? onPressed;
  final Widget? child;
  final double? height;
  final double? width;
  final Color? backColor;
  final Color? txtColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final Color borderColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: padding,
      elevation: elevation ?? 1,
      height: height ?? 48,
      minWidth: width ?? double.infinity,
      color: backColor ??
          (isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor),
      textColor: txtColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor),
        borderRadius: borderRadius ?? BorderRadius.circular(56),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

class CustomTextButton extends StatelessWidget {
  const CustomTextButton(
      {super.key, required this.onPressed, required this.child, this.color});

  final void Function()? onPressed;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: color,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
