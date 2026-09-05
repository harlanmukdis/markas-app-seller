import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../generated/l10n.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: customAppBar(context, l.forgetPassword),
      body: SingleChildScrollView(
        padding: 24.psh,
        child: Column(
          children: [
            28.sbh,
            Center(
              child: SvgPicture.asset(
                AppImages.forgetPassword,
                fit: BoxFit.cover,
              ),
            ),
            24.sbh,
            Text(
              l.toResetYourPassword,
              style: AppStyles.styleRegular16(context).copyWith(
                  color: isAppDarkMode()
                      ? kDarkThirdColor
                      : const Color(0xff555555)),
            ),
            24.sbh,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isAppDarkMode()
                        ? kDarkPrimaryColor
                        : kLightPrimaryColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xffDAE8FF)),
                    child: Icon(
                      Icons.email,
                      color: isAppDarkMode()
                          ? kDarkPrimaryColor
                          : kLightPrimaryColor,
                    ),
                  ),
                  24.sbw,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l.viaPhone} :',
                        style: AppStyles.styleRegular14(context).copyWith(
                            color: isAppDarkMode()
                                ? kDarkThirdColor
                                : kLightThirdColor),
                      ),
                      8.sbh,
                      Text(
                        '+880***7763666',
                        style: AppStyles.styleMedium14(context).copyWith(
                            color: isAppDarkMode()
                                ? kDarkThirdColor
                                : kLightThirdColor),
                      )
                    ],
                  )
                ],
              ),
            ),
            13.sbh,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffDAE8FF)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xffDAE8FF)),
                    child: Icon(
                      Icons.email,
                      color: isAppDarkMode()
                          ? kDarkPrimaryColor
                          : kLightPrimaryColor,
                    ),
                  ),
                  24.sbw,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l.viaEmail} :',
                        style: AppStyles.styleRegular14(context).copyWith(
                            color: isAppDarkMode()
                                ? kDarkThirdColor
                                : kLightThirdColor),
                      ),
                      8.sbh,
                      Text(
                        'info***ul@gmail.com',
                        style: AppStyles.styleMedium14(context).copyWith(
                            color: isAppDarkMode()
                                ? kDarkThirdColor
                                : kLightThirdColor),
                      )
                    ],
                  )
                ],
              ),
            ),
            24.sbh,
            CustomButton(
              onPressed: () => router.push(AppRoutes.otpVerification),
              child: Text(
                l.continuee,
                style: AppStyles.styleMedium16(context)
                    .copyWith(color: kWhiteColor),
              ),
            ),
            8.sbh,
          ],
        ),
      ),
    );
  }
}
