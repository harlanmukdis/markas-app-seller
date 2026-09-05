import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../generated/l10n.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return SingleChildScrollView(
      padding: 24.psh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l.recentNotifications,
                style: AppStyles.styleMedium16(context).copyWith(
                    color:
                        isAppDarkMode() ? const Color(0xffF7F7F7) : kDarkColor),
              ),
              10.sbw,
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
                ),
                child: Center(
                  child: Text(
                    '2',
                    style: AppStyles.styleRegular12(context)
                        .copyWith(color: const Color(0xffF4F4F4)),
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  l.clearAll,
                  style: AppStyles.styleRegular16(context).copyWith(
                      color: isAppDarkMode()
                          ? kDarkPrimaryColor
                          : kLightPrimaryColor),
                ),
              ),
            ],
          ),
          24.sbh,
          Text(
            l.today,
            style: AppStyles.styleMedium16(context)
                .copyWith(color: isAppDarkMode() ? null : kLightThirdColor),
          ),
          16.sbh,
          _buildContainer(
            context,
            'We have bookmarked a property “Casa De Leone” for you. Find out more about the property!',
          ),
          14.sbh,
          _buildContainer(
            context,
            'Patrick Leone just messages you! Come and reply right now',
          ),
          14.sbh,
          _buildContainer(
            context,
            'Your offer on “Casa De Leone” is aprroved. Come check it out!',
          ),
          24.sbh,
          Text(
            l.yesterday,
            style: AppStyles.styleMedium16(context).copyWith(
              color: isAppDarkMode() ? kDarkThirdColor : kLightThirdColor,
            ),
          ),
          16.sbh,
          _buildContainer(context,
              '11 hotels and resorts in Malaysia with private swimming pool in central city is having deal... '),
          14.sbh,
          _buildContainer(context,
              '11 hotels and resorts in Malaysia with private swimming pool in central city is having deal... '),
          16.sbh,
        ],
      ),
    );
  }

  Widget _buildContainer(BuildContext context, String text) {
    return Container(
      padding: 12.pa,
      decoration: ShapeDecoration(
        color: isAppDarkMode() ? kLightSecondColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: [
          BoxShadow(
            color: const Color(0x115A6CEA).withOpacity(0.07),
            blurRadius: 50,
            offset: const Offset(12, 26),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AppImages.notificationImg,
            fit: BoxFit.cover,
            width: 33,
            height: 33,
            color: isAppDarkMode() ? kDarkThirdColor : null,
          ),
          12.sbw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: AppStyles.styleRegular14(context).copyWith(
                      color: isAppDarkMode()
                          ? kDarkSecondColor
                          : const Color(0xff2B2B2B)),
                ),
                8.sbh,
                Text(
                  isLanguageRTL() ? 'منذ ساعتين' : '2 hours Ago',
                  style: AppStyles.styleMedium12(context).copyWith(
                      color: isAppDarkMode()
                          ? kDarkThirdColor
                          : const Color(0xffB8B8B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
