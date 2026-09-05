import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../generated/l10n.dart';

class PaymentMethodsView extends StatelessWidget {
  const PaymentMethodsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: customAppBar(context, l.paymentMethods),
      body: Padding(
        padding: 24.psh,
        child: Column(
          children: [
            24.sbh,
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffF3F4F6),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppImages.paymentIcon2,
                      fit: BoxFit.cover,
                      width: 16,
                    ),
                  ),
                ),
                12.sbw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.payPal,
                        style: AppStyles.styleSemiBold16(context).copyWith(
                            color: isAppDarkMode()
                                ? kDarkSecondColor
                                : kLightSecondColor),
                      ),
                      5.sbh,
                      Text(
                        '**** **** **** 87652',
                        style: AppStyles.styleSemiBold14(context).copyWith(
                            color: isAppDarkMode()
                                ? kDarkThirdColor
                                : const Color(0xff5A5A5A)),
                      ),
                      8.sbh,
                      Text(
                        'Mahmodul Hasan',
                        style: AppStyles.styleMedium14(context).copyWith(
                            color: isAppDarkMode()
                                ? const Color(0xffD0D0D0)
                                : const Color(0xffB8B8B8)),
                      ),
                    ],
                  ),
                ),
                12.sbw,
                Checkbox(
                  shape: const CircleBorder(),
                  value: true,
                  onChanged: (_) {},
                ),
              ],
            ),
            24.sbh,
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: 10.pt,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffF3F4F6),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppImages.paymentIcon1,
                      fit: BoxFit.scaleDown,
                      height: 34,
                    ),
                  ),
                ),
                12.sbw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.masterCard,
                        style: AppStyles.styleSemiBold16(context).copyWith(
                            color: isAppDarkMode()
                                ? kDarkSecondColor
                                : kLightSecondColor),
                      ),
                      5.sbh,
                      Text(
                        '**** **** **** 87652',
                        style: AppStyles.styleSemiBold14(context).copyWith(
                            color: isAppDarkMode()
                                ? kDarkThirdColor
                                : const Color(0xff5A5A5A)),
                      ),
                      8.sbh,
                      Text(
                        'Mahmodul Hasan',
                        style: AppStyles.styleMedium14(context).copyWith(
                            color: isAppDarkMode()
                                ? const Color(0xffD0D0D0)
                                : const Color(0xffB8B8B8)),
                      ),
                    ],
                  ),
                ),
                12.sbw,
                Checkbox(
                  shape: const CircleBorder(),
                  value: false,
                  onChanged: (_) {},
                ),
              ],
            ),
            const Spacer(),
            CustomButton(
              onPressed: () => router.push(AppRoutes.addCardView),
              child: Text(
                l.addNewCard,
                style: AppStyles.styleMedium16(context),
              ),
            ),
            16.sbh,
          ],
        ),
      ),
    );
  }
}
