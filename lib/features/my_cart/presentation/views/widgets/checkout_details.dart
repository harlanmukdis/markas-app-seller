import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../../core/function/components.dart';
import '../../../../../core/utils/app_routes.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/widgets/custom_buttons.dart';
import '../../../../../core/widgets/custom_text_form_field.dart';
import '../../../../../generated/l10n.dart';

class CheckoutDetails extends StatelessWidget {
  const CheckoutDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0, left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.addMoreItems,
                    style: AppStyles.styleMedium16(context).copyWith(
                      color: isAppDarkMode()
                          ? kDarkPrimaryColor
                          : kLightPrimaryColor,
                    )),
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 20,
                  color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
                ),
              ],
            ),
          ),
        ),
        const Divider(
          thickness: 1,
          color: Color(0xffBDBDBD),
          height: 16,
        ),
        Row(
          children: [
            Text(l.promoCode,
                textAlign: TextAlign.start,
                style: AppStyles.styleSemiBold14(context)),
          ],
        ),
        8.sbh,
        CustomTextFormField(
          hintText: l.enterCodeVoucher,
          filled: isAppDarkMode() ? true : false,
          fillColor: kBlackColor,
          suffix: Padding(
            padding: 8.pe,
            child: TextButton(
              child: Text(l.apply,
                  style: AppStyles.styleMedium14(context).copyWith(
                      color: isAppDarkMode()
                          ? kDarkPrimaryColor
                          : kLightPrimaryColor)),
              onPressed: () {},
            ),
          ),
        ),
        8.sbh,
        Row(
          children: [
            Text(l.subtotal,
                textAlign: TextAlign.start,
                style: AppStyles.styleSemiBold14(context)),
            const Spacer(),
            Text("\$ 29.4",
                style: AppStyles.styleMedium18(context).copyWith(
                  color:
                      isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
                ))
          ],
        ),
        Row(
          children: [
            Text(l.delivery,
                textAlign: TextAlign.start,
                style: AppStyles.styleSemiBold14(context)),
            const Spacer(),
            Text("\$ 29.4",
                style: AppStyles.styleMedium18(context).copyWith(
                  color:
                      isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
                ))
          ],
        ),
        Row(
          children: [
            Text(l.promoCode,
                textAlign: TextAlign.start,
                style: AppStyles.styleSemiBold14(context)),
            const Spacer(),
            Text(
              "\$ 0",
              style: AppStyles.styleMedium18(context).copyWith(
                color: isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
              ),
            ),
          ],
        ),
        const Divider(
          thickness: 1,
          color: Color(0xffBDBDBD),
          height: 16,
        ),
        Row(
          children: [
            Text("${l.total} (incl. VAT)",
                textAlign: TextAlign.start,
                style: AppStyles.styleSemiBold16(context)),
            const Spacer(),
            Text("\$ 29.4",
                style: AppStyles.styleMedium18(context).copyWith(
                  color:
                      isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
                ))
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        CustomButton(
          onPressed: () {
            router.push(AppRoutes.checkout);
          },
          child: Center(
            child: Text(l.continuee,
                style: AppStyles.styleMedium16(context)
                    .copyWith(color: Colors.white)),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }
}
