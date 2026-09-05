import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../generated/l10n.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: 24.psh,
      child: Column(
        children: [
          16.sbh,
          SafeArea(
            child: Center(
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
                      onTap: () => router.push(AppRoutes.editProfile),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const ShapeDecoration(
                          color: Color(0xFFF6F8FA),
                          shape: OvalBorder(),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 18,
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
          ),
          20.sbh,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mahmodul Hasan',
                style: AppStyles.styleSemiBold18(context).copyWith(
                    color: isAppDarkMode()
                        ? kDarkSecondColor
                        : const Color(0xff2b2b2b)),
              ),
              8.sbw,
              SvgPicture.asset(AppImages.verified),
            ],
          ),
          6.sbh,
          Text(
            'info.mamodul@gmail.com',
            style: AppStyles.styleRegular14(context).copyWith(
                color: isAppDarkMode()
                    ? const Color(0xffD0D0D0)
                    : const Color(0xff999999)),
          ),
          24.sbh,
          const GeneralWidgets()
        ],
      ),
    );
  }
}

class GeneralWidgets extends StatelessWidget {
  const GeneralWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.general, style: AppStyles.styleMedium16(context)),
        10.sbh,
        _customListTile(
          context,
          title: l.profileInformation,
          icon: Icons.person_outline,
          onTap: () => router.push(AppRoutes.editProfile),
        ),
        _customListTile(
          context,
          title: l.notifications,
          icon: Icons.notifications_none_outlined,
          onTap: () => router.push(AppRoutes.notifications),
        ),
        // _customListTile(context,
        //     title: l.myFavorites, icon: Icons.favorite_border_outlined),
        _customListTile(
          context,
          title: l.forgetPassword,
          icon: Icons.key_outlined,
          onTap: () => router.push(AppRoutes.forgotPassword),
        ),
        _customListTile(
          context,
          title: l.paymentMethods,
          icon: Icons.payment_outlined,
          onTap: () => router.push(AppRoutes.paymentMethods),
        ),
        _customListTile(
          context,
          title: l.settings,
          icon: Icons.settings_outlined,
          onTap: () => router.push(AppRoutes.settings),
        ),
        _customListTile(
          context,
          title: l.aboutShopapay,
          icon: Icons.info_outline,
          onTap: () => router.push(AppRoutes.aboutApp),
        ),
        16.sbh,
        Text(
          l.homeSearch,
          style: AppStyles.styleMedium16(context).copyWith(
              color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor),
        ),
        8.sbh,
        _customListTile(context,
            title: l.rateUs, icon: Icons.star_border_outlined),
        _customListTile(
          context,
          title: l.helpCenter,
          icon: Icons.help_outline,
          onTap: () => router.push(AppRoutes.helpCenter),
        ),
        _customListTile(
          context,
          title: l.logOut,
          icon: Icons.logout_outlined,
          onTap: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding: 32.pa,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l.areYouSureYouWantToLogOut,
                    textAlign: TextAlign.center,
                    style: AppStyles.styleSemiBold18(context),
                  ),
                  30.sbh,
                  CustomButton(
                    child: Text(
                      l.cancel,
                      style: AppStyles.styleMedium14(context)
                          .copyWith(color: kWhiteColor),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  16.sbh,
                  TextButton(
                    child: Text(
                      l.logOut,
                      style: AppStyles.styleSemiBold14(context)
                          .copyWith(color: const Color(0xffD32F2F)),
                    ),
                    onPressed: () => router.go(AppRoutes.login),
                  ),
                ],
              ),
            ),
          ),
        ),
        8.sbh,
      ],
    );
  }

  Widget _customListTile(BuildContext context,
      {required String title, required IconData icon, void Function()? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 0,
      minVerticalPadding: 0,
      onTap: onTap ?? () {},
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xffDAE8FF),
        ),
        child: Icon(
          icon,
          color: isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppStyles.styleMedium14(context).copyWith(
            color: isAppDarkMode() ? kDarkThirdColor : const Color(0xff555555)),
      ),
      trailing: Icon(
        isLanguageRTL()
            ? Icons.keyboard_arrow_left_outlined
            : Icons.keyboard_arrow_right_outlined,
        color: isAppDarkMode() ? kDarkSecondColor : kLightThirdColor,
      ),
    );
  }
}
