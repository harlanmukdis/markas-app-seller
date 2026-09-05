import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../generated/l10n.dart';

class AddCardView extends StatelessWidget {
  const AddCardView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: customAppBar(context, l.addCard),
      body: Padding(
        padding: 24.psh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            24.sbh,
            Text(
              l.cardNumber,
              style: AppStyles.styleMedium14(context).copyWith(
                  color: isAppDarkMode() ? kDarkSecondColor : kLightThirdColor),
            ),
            8.sbh,
            CustomTextFormField(
              filled: true,
              hintText: l.enterYourCard,
            ),
            20.sbh,
            Text(
              l.cardHolderName,
              style: AppStyles.styleMedium14(context).copyWith(
                  color: isAppDarkMode() ? kDarkSecondColor : kLightThirdColor),
            ),
            8.sbh,
            CustomTextFormField(
              filled: true,
              hintText: l.enterHolderName,
            ),
            28.sbh,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.expired,
                        style: TextStyle(
                            color: isAppDarkMode()
                                ? kDarkSecondColor
                                : const Color(0xff555555)),
                      ),
                      8.sbh,
                      const CustomTextFormField(
                        filled: true,
                        hintText: 'MM/YY',
                      ),
                    ],
                  ),
                ),
                12.sbw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CVV ${l.code}',
                        style: TextStyle(
                            color: isAppDarkMode()
                                ? kDarkSecondColor
                                : const Color(0xff555555)),
                      ),
                      8.sbh,
                      const CustomTextFormField(
                        filled: true,
                        hintText: 'CVV',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            CustomButton(
              onPressed: () {},
              child: Text(
                l.addNewCard,
                style: AppStyles.styleMedium16(context)
                    .copyWith(color: Colors.white),
              ),
            ),
            16.sbh
          ],
        ),
      ),
    );
  }
}
