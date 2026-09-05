import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../generated/l10n.dart';

class OtpVerificationView extends StatelessWidget {
  const OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: customAppBar(context, l.otpVerification),
      body: SingleChildScrollView(
        padding: 24.psh,
        child: Center(
          child: Column(
            children: [
              24.sbh,
              Text(
                l.enterYourOtp,
                style: AppStyles.styleSemiBold24(context),
              ),
              16.sbh,
              Text(
                '${l.codeHasSentTo} +880***7763666',
                style: AppStyles.styleRegular16(context).copyWith(
                  color: isAppDarkMode() ? kDarkThirdColor : kLightThirdColor,
                ),
              ),
              32.sbh,
              Pinput(
                animationCurve: Curves.bounceIn,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                // controller: _cubit.registerOtpController,
                onCompleted: (code) => debugPrint(code),
                length: 6,
              ),
              24.sbh,
              OtpTimerButton(
                backgroundColor:
                    isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
                onPressed: () {},
                text: Text(
                  l.pleaseWait,
                  style: AppStyles.styleRegular12(context).copyWith(
                    color: isAppDarkMode()
                        ? kDarkSecondColor
                        : const Color(0xffAAAAAA),
                  ),
                ),
                duration: 120,
              ),
              82.sbh,
              CustomButton(
                onPressed: () => router.push(AppRoutes.createNewPassword),
                child: Text(
                  l.submit,
                  style: AppStyles.styleMedium16(context)
                      .copyWith(color: kWhiteColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
