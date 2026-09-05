import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../generated/l10n.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final PageController _controller = PageController(initialPage: 0);
  int _currentPage = 0;

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
      body: Padding(
        padding: 24.psh,
        child: Column(
          children: [
            (context.screenHeight * .1).sbh,
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildEnterEmail(context, l),
                  _buildEnterOtp(context, l),
                  _buildEnterPassword(context, l),
                ],
              ),
            ),
            CustomButton(
              onPressed: () {
                if (_currentPage < 2) {
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeIn);
                }
              },
              child: Text(
                _currentPage == 1 ? l.verify : l.continuee,
                style: AppStyles.styleRegular16(context)
                    .copyWith(color: Colors.white),
              ),
            ),
            32.sbh,
          ],
        ),
      ),
    );
  }

  Widget _buildEnterEmail(BuildContext context, S l) {
    return Column(
      children: [
        Text(
          l.resetPassword,
          style: AppStyles.styleSemiBold24(context),
        ),
        16.sbh,
        Text(
          l.enterYourEmailThenWeWillSendYouOTP,
          textAlign: TextAlign.center,
          style: AppStyles.styleRegular16(context).copyWith(
              color: isAppDarkMode()
                  ? const Color(0xffE8E8E8)
                  : kLightSecondColor),
        ),
        24.sbh,
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l.email,
            style: AppStyles.styleMedium14(context),
          ),
        ),
        8.sbh,
        CustomTextFormField(
          filled: true,
          hintText: l.enterYourEmail,
        )
      ],
    );
  }

  Widget _buildEnterOtp(BuildContext context, S l) {
    return Column(
      children: [
        Text(
          l.enterOtp,
          style: AppStyles.styleSemiBold24(context),
        ),
        24.sbh,
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
              color: const Color(0xffAAAAAA),
            ),
          ),
          duration: 120,
        ),
      ],
    );
  }

  Widget _buildEnterPassword(BuildContext context, S l) {
    return Column(
      children: [
        Text(
          l.resetPassword,
          style: AppStyles.styleSemiBold24(context),
        ),
        16.sbh,
        Text(
          l.enterYourNawPasswordRememberThisTime,
          textAlign: TextAlign.center,
          style: AppStyles.styleRegular16(context).copyWith(
              color: isAppDarkMode() ? kDarkThirdColor : kLightThirdColor),
        ),
        24.sbh,
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l.password,
            style: AppStyles.styleMedium14(context),
          ),
        ),
        8.sbh,
        const CustomTextFormField(
          filled: true,
          hintText: '********',
          prefix: Icon(Icons.lock_outline),
          suffix: Icon(Icons.remove_red_eye_outlined),
        ),
        20.sbh,
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l.confirmPassword,
            style: AppStyles.styleMedium14(context),
          ),
        ),
        8.sbh,
        const CustomTextFormField(
          filled: true,
          hintText: '********',
          prefix: Icon(Icons.lock_outline),
          suffix: Icon(Icons.remove_red_eye_outlined),
        )
      ],
    );
  }
}
