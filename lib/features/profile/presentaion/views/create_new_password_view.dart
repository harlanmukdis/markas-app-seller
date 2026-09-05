import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../generated/l10n.dart';

class CreateNewPasswordView extends StatelessWidget {
  const CreateNewPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: customAppBar(context, l.createNewPassword),
      body: SingleChildScrollView(
        padding: 24.psh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            24.sbh,
            Center(
              child: SvgPicture.asset(
                AppImages.newPassword,
                fit: BoxFit.cover,
              ),
            ),
            24.sbh,
            Text(
              l.createNewPassword,
              style: AppStyles.styleMedium20(context).copyWith(
                color: isAppDarkMode() ? kDarkThirdColor : null,
              ),
            ),
            24.sbh,
            Text(
              l.password,
              style: AppStyles.styleRegular14(context).copyWith(
                color: isAppDarkMode()
                    ? kDarkSecondColor
                    : const Color(0xff2B2B2B),
              ),
            ),
            12.sbh,
            const CustomTextFormField(
              filled: true,
              hintText: '********',
              prefix: Icon(Icons.lock_outline),
              suffix: Icon(Icons.remove_red_eye_outlined),
            ),
            20.sbh,
            Text(
              l.confirmPassword,
              style: AppStyles.styleRegular14(context).copyWith(
                color: isAppDarkMode()
                    ? kDarkSecondColor
                    : const Color(0xff2B2B2B),
              ),
            ),
            12.sbh,
            const CustomTextFormField(
              filled: true,
              hintText: '********',
              prefix: Icon(Icons.lock_outline),
              suffix: Icon(Icons.remove_red_eye_outlined),
            ),
            8.sbh,
            Row(
              children: [
                Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  value: true,
                  onChanged: (_) {},
                ),
                Text(
                  l.rememberMe,
                  style: AppStyles.styleRegular12(context),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
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
            34.sbh,
            CustomButton(
              onPressed: () {},
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
