import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../generated/l10n.dart';

class ContactUsView2 extends StatelessWidget {
  const ContactUsView2({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: customAppBar(context, l.contactUs),
      body: SingleChildScrollView(
        padding: 24.psh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            24.sbh,
            Text(l.howCanWeHelpYou, style: AppStyles.styleMedium16(context)),
            16.sbh,
            Container(
              decoration: isAppDarkMode()
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xffBDD8FF).withOpacity(.2)),
                    )
                  : null,
              child: CustomTextFormField(
                filled: isAppDarkMode() ? true : false,
                hintText: l.typeHere,
                maxLines: 8,
              ),
            ),
            82.sbh,
            CustomButton(
              onPressed: () {},
              child: Text(
                l.submit,
                style: AppStyles.styleMedium16(context)
                    .copyWith(color: kWhiteColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
