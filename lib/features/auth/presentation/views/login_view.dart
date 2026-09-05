import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../generated/l10n.dart';
import 'widgets/social_media_widgets.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: customAppBar(
        context,
        '',
        action: TextButton(
          onPressed: () {},
          child: Text(
            l.needHelp,
            style: AppStyles.styleRegular14(context).copyWith(
                color: isAppDarkMode()
                    ? const Color(0xff5A9BFF)
                    : isAppDarkMode()
                        ? kDarkPrimaryColor
                        : kLightPrimaryColor,
                decoration: TextDecoration.underline),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: 24.psh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (context.screenHeight * .1).sbh,
            Center(
              child: Text(
                l.welcomeBack,
                style: AppStyles.styleSemiBold24(context)
                    .copyWith(color: isAppDarkMode() ? null : kDarkColor),
              ),
            ),
            16.sbh,
            Center(
              child: Text(
                l.logInToAccessYourPersonalized,
                textAlign: TextAlign.center,
                style: AppStyles.styleRegular16(context).copyWith(
                    color: isAppDarkMode()
                        ? const Color(0xffE8E8E8)
                        : const Color(0xff555555)),
              ),
            ),
            24.sbh,
            Text(
              l.name,
              style: AppStyles.styleMedium14(context)
                  .copyWith(color: isAppDarkMode() ? null : kLightThirdColor),
            ),
            8.sbh,
            CustomTextFormField(
              filled: true,
              hintText: l.enterYourName,
            ),
            16.sbh,
            Text(
              l.email,
              style: AppStyles.styleMedium14(context)
                  .copyWith(color: isAppDarkMode() ? null : kLightThirdColor),
            ),
            8.sbh,
            CustomTextFormField(
              filled: true,
              hintText: l.enterYourEmail,
            ),
            8.sbh,
            Row(
              children: [
                Checkbox(
                  shape: const CircleBorder(),
                  value: false,
                  onChanged: (v) {},
                ),
                Text(l.rememberMe, style: AppStyles.styleRegular14(context)),
                const Spacer(),
                TextButton(
                  onPressed: () => router.push(AppRoutes.resetPassword),
                  child: Text(
                    l.forgetPassword,
                    style: AppStyles.styleRegular12(context).copyWith(
                        color: isAppDarkMode()
                            ? kDarkPrimaryColor
                            : kLightPrimaryColor),
                  ),
                ),
              ],
            ),
            16.sbh,
            CustomButton(
              onPressed: () => router.go(AppRoutes.homeLayout),
              child: Text(
                l.continuee,
                style: AppStyles.styleMedium16(context)
                    .copyWith(color: Colors.white),
              ),
            ),
            24.sbh,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    margin: 16.pe,
                    height: 1,
                    color: const Color(0xFFBDBDBD),
                  ),
                ),
                Text(
                  l.or,
                  style: AppStyles.styleMedium18(context).copyWith(
                    color: const Color(0xff616161),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: 16.ps,
                    height: 1,
                    color: const Color(0xFFBDBDBD),
                  ),
                ),
              ],
            ),
            24.sbh,
            buildSocialLoginButtons(context),
            62.sbh,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l.dontHaveAccount,
                    style: AppStyles.styleRegular16(context)),
                TextButton(
                  onPressed: () => router.push(AppRoutes.register),
                  child: Text(
                    l.register,
                    style: AppStyles.styleRegular14(context).copyWith(
                        color: isAppDarkMode()
                            ? kDarkPrimaryColor
                            : kLightPrimaryColor),
                  ),
                ),
              ],
            ),
            16.sbh
          ],
        ),
      ),
    );
  }
}
