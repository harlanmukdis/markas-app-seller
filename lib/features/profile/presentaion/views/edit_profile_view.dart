import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../generated/l10n.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: customAppBar(context, l.editProfile),
      body: SingleChildScrollView(
        padding: 24.psh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            24.sbh,
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      AppImages.profileImg,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {},
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const ShapeDecoration(
                          color: Color(0xFFF6F8FA),
                          shape: OvalBorder(),
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 17,
                          color: isAppDarkMode()
                              ? kDarkPrimaryColor
                              : kLightPrimaryColor,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            28.sbh,
            Text(
              l.name,
              style: AppStyles.styleMedium14(context).copyWith(
                color: isAppDarkMode()
                    ? kDarkSecondColor
                    : const Color(0xff555555),
              ),
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
                color: isAppDarkMode()
                    ? kDarkSecondColor
                    : const Color(0xff555555),
              ),
            ),
            8.sbh,
            CustomTextFormField(
              filled: true,
              hintText: l.enterYourEmail,
            ),
            16.sbh,
            Text(
              l.address,
              style: AppStyles.styleMedium14(context).copyWith(
                color: isAppDarkMode()
                    ? kDarkSecondColor
                    : const Color(0xff555555),
              ),
            ),
            8.sbh,
            CustomTextFormField(
              filled: true,
              hintText: l.enterYourAddress,
            ),
            16.sbh,
            Text(
              l.password,
              style: AppStyles.styleMedium14(context).copyWith(
                color: isAppDarkMode()
                    ? kDarkSecondColor
                    : const Color(0xff555555),
              ),
            ),
            8.sbh,
            CustomTextFormField(
              prefix: const Icon(Icons.lock_outline),
              suffix: const Icon(Icons.remove_red_eye_outlined),
              filled: true,
              hintText: l.password,
            ),
            56.sbh,
            CustomButton(
              onPressed: () {},
              child: Text(
                l.save,
                style: AppStyles.styleMedium16(context)
                    .copyWith(color: Colors.white),
              ),
            ),
            8.sbh,
          ],
        ),
      ),
    );
  }
}
