import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../utils/app_styles.dart';
import '../utils/constant.dart';
import 'components.dart';

customAppBar(BuildContext context, String title, {Widget? action}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    title: Text(
      title,
      style: AppStyles.styleMedium18(context).copyWith(
        color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
      ),
    ),
    leading: Padding(
      padding: 16.ps,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: isAppDarkMode()
                ? null
                : Border.all(color: const Color(0xffBDD8FF), width: .2),
            shape: BoxShape.circle,
            color: isAppDarkMode() ? kBlackColor : const Color(0xffF8F8F8),
          ),
          child: Icon(
            size: 20,
            Icons.arrow_back_ios_new_outlined,
            color: isAppDarkMode()
                ? isAppDarkMode()
                    ? kDarkSecondColor
                    : kLightSecondColor
                : isAppDarkMode()
                    ? kDarkSecondColor
                    : kLightSecondColor,
          ),
        ),
      ),
    ),
    actions: [
      Padding(
        padding: 16.pe,
        child: action ?? Container(),
      )
    ],
  );
}
