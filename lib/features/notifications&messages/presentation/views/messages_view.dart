import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../generated/l10n.dart';

class MessagesView extends StatelessWidget {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return SingleChildScrollView(
      padding: 24.psh,
      child: Column(
        children: [
          4.sbh,
          CustomTextFormField(
            filled: isAppDarkMode() ? true : false,
            hintText: '${l.search}...',
            prefix: SvgPicture.asset(
              AppImages.search,
              fit: BoxFit.scaleDown,
              colorFilter: ColorFilter.mode(
                  isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
                  BlendMode.srcIn),
            ),
            suffix: SvgPicture.asset(
              AppImages.filter,
              fit: BoxFit.scaleDown,
              colorFilter: ColorFilter.mode(
                  isAppDarkMode() ? kDarkThirdColor : kLightThirdColor,
                  BlendMode.srcIn),
            ),
          ),
          24.sbh,
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) => Padding(
              padding: 20.pb,
              child: InkWell(
                onTap: () => router.push(AppRoutes.chat),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            AppImages.person,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xff1DA02A),
                            ),
                          ),
                        )
                      ],
                    ),
                    16.sbw,
                    Expanded(
                      child: Padding(
                        padding: 6.psv,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Jhalok Deb ',
                                  style: AppStyles.styleMedium16(context),
                                ),
                                8.sbw,
                                Text(
                                  '15:23',
                                  style: AppStyles.styleRegular12(context)
                                      .copyWith(color: const Color(0xff999999)),
                                )
                              ],
                            ),
                            8.sbh,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Thanks for contacting me!',
                                  style: AppStyles.styleMedium16(context)
                                      .copyWith(
                                          color: isAppDarkMode()
                                              ? kDarkThirdColor
                                              : null),
                                ),
                                8.sbw,
                                Container(
                                  height: 20,
                                  width: 20,
                                  decoration: const ShapeDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(-0.96, 0.28),
                                      end: Alignment(0.96, -0.28),
                                      colors: [
                                        Color(0xFF246BFD),
                                        Color(0xFF4F89FF)
                                      ],
                                    ),
                                    shape: OvalBorder(),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '2',
                                      style: AppStyles.styleSemiBold12(context)
                                          .copyWith(color: kWhiteColor),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    2.sbw
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
