import 'package:flutter/gestures.dart';
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

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

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
                color: isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
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
                l.registerYourNewAccount,
                textAlign: TextAlign.center,
                style: AppStyles.styleSemiBold24(context).copyWith(
                    color: isAppDarkMode() ? kDarkSecondColor : kDarkColor),
              ),
            ),
            16.sbh,
            Center(
              child: Text(
                l.enterYourInformationBelow,
                textAlign: TextAlign.center,
                style: AppStyles.styleRegular16(context).copyWith(
                    color: isAppDarkMode()
                        ? const Color(0xffE8E8E8)
                        : const Color(0xff555555)),
              ),
            ),
            16.sbh,
            Text(
              l.name,
              style: AppStyles.styleMedium14(context).copyWith(
                  color: isAppDarkMode() ? kDarkThirdColor : kLightThirdColor),
            ),
            8.sbh,
            CustomTextFormField(
              filled: true,
              hintText: l.enterYourName,
            ),
            16.sbh,
            Text(
              l.email,
              style: AppStyles.styleMedium14(context).copyWith(
                  color: isAppDarkMode() ? kDarkThirdColor : kLightThirdColor),
            ),
            8.sbh,
            CustomTextFormField(
              filled: true,
              hintText: l.enterYourEmail,
            ),
            16.sbh,
            Text(
              l.password,
              style: AppStyles.styleMedium14(context).copyWith(
                  color: isAppDarkMode() ? kDarkThirdColor : kLightThirdColor),
            ),
            8.sbh,
            CustomTextFormField(
              filled: true,
              hintText: l.password,
              prefix: const Icon(Icons.lock_outline),
              suffix: const Icon(Icons.remove_red_eye_outlined),
            ),
            8.sbh,
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Checkbox(
                  shape: const CircleBorder(),
                  value: true,
                  onChanged: (v) {},
                ),
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      text: l.byCreatingAccountYouAgreeToOur,
                      style: AppStyles.styleRegular14(context),
                      children: [
                        TextSpan(
                          text: l.termsAndConditions,
                          style: AppStyles.styleRegular14(context).copyWith(
                              color: isAppDarkMode()
                                  ? kDarkPrimaryColor
                                  : kLightPrimaryColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // print('hi');
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            20.sbh,
            CustomButton(
              onPressed: () => router.go(AppRoutes.homeLayout),
              child: Text(
                l.createAccount,
                style: AppStyles.styleMedium16(context)
                    .copyWith(color: Colors.white),
              ),
            ),
            16.sbh,
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
            16.sbh,
            buildSocialLoginButtons(context),
            20.sbh
          ],
        ),
      ),
    );
  }
}
