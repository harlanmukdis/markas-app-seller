import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../generated/l10n.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: 24.psh,
        child: Column(
          children: [
            (context.screenHeight * .1).sbh,
            SafeArea(
              child: Center(child: SvgPicture.asset(AppImages.welcome)),
            ),
            32.sbh,
            Text(
              l.letsYouIn,
              style: AppStyles.styleSemiBold24(context),
            ),
            24.sbh,
            _buildSocialLoginButton(
              context: context,
              icon: AppImages.google,
              label: l.continueWithGoogle,
            ),
            16.sbh,
            _buildSocialLoginButton(
              context: context,
              icon: AppImages.facebook,
              label: l.continueWithFacebook,
            ),
            16.sbh,
            _buildSocialLoginButton(
              context: context,
              icon: AppImages.apple,
              label: l.continueWithApple,
              iconColor: isAppDarkMode()
                  ? const ColorFilter.mode(kWhiteColor, BlendMode.srcIn)
                  : null,
            ),
            28.sbh,
            _buildOrDivider(context, l.or),
            28.sbh,
            CustomButton(
              onPressed: () => router.push(AppRoutes.login),
              child: Text(
                l.signInWithPassword,
                style: AppStyles.styleMedium16(context)
                    .copyWith(color: kWhiteColor),
              ),
            ),
            56.sbh,
            _buildSignUpRow(context, l),
            16.sbh
          ],
        ),
      ),
    );
  }

  // Helper method to build social login buttons
  Widget _buildSocialLoginButton({
    required BuildContext context,
    required String icon,
    required String label,
    ColorFilter? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: ShapeDecoration(
        color: isAppDarkMode() ? kLightSecondColor : kWhiteColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isAppDarkMode()
                ? const Color(0xffBDBDBD).withOpacity(.3)
                : const Color(0xFFEEEEEE),
          ),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(icon, colorFilter: iconColor),
          12.sbw,
          Text(
            label,
            style: AppStyles.styleMedium16(context),
          ),
        ],
      ),
    );
  }

  // Helper method to build the OR divider
  Widget _buildOrDivider(BuildContext context, String orLabel) {
    return Row(
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
          orLabel,
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
    );
  }

  // Helper method to build the SignUp row
  Widget _buildSignUpRow(BuildContext context, S l) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l.dontHaveAccount,
          style: AppStyles.styleRegular16(context),
        ),
        8.sbw,
        TextButton(
          onPressed: () => router.push(AppRoutes.register),
          child: Text(
            l.signUp,
            style: AppStyles.styleSemiBold16(context).copyWith(
              color: isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
