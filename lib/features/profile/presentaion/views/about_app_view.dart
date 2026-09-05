import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../generated/l10n.dart';

class AboutAppView extends StatelessWidget {
  const AboutAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: customAppBar(context, l.aboutShopapay),
      body: Center(
        child: Padding(
          padding: 24.psh,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(AppImages.logo),
              16.sbh,
              SvgPicture.asset(
                AppImages.Shopapay,
                fit: BoxFit.scaleDown,
                width: 200,
              ),
              32.sbh,
              _buildContainer(context, title: l.jobVacancy),
              _buildContainer(context, title: l.privacyPolicy),
              _buildContainer(context, title: l.accessibility),
              _buildContainer(context, title: l.rateUs),
              _buildContainer(context, title: l.followUs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(BuildContext context,
      {required String title, void Function()? onTap}) {
    return Padding(
      padding: 8.pb,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Container(
          padding: 16.psv,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xffD9D9D9)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppStyles.styleMedium16(context),
              ),
              Icon(
                isLanguageRTL()
                    ? Icons.keyboard_arrow_left_outlined
                    : Icons.keyboard_arrow_right_outlined,
                color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}
