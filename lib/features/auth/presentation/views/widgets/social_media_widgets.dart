import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/function/components.dart';
import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/constant.dart';

Widget buildSocialLoginButtons(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _buildSocialButton(context, AppImages.facebook),
      _buildSocialButton(context, AppImages.google),
      _buildSocialButton(context, AppImages.apple, isApple: true),
    ],
  );
}

Widget _buildSocialButton(BuildContext context, String icon,
    {bool isApple = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    decoration: ShapeDecoration(
      color: isAppDarkMode() ? kLightSecondColor : kWhiteColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: isAppDarkMode()
                ? const Color(0xffBDBDBD)
                : const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    child: SvgPicture.asset(
      icon,
      colorFilter: isApple && isAppDarkMode()
          ? const ColorFilter.mode(kWhiteColor, BlendMode.srcIn)
          : null,
    ),
  );
}
