import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../generated/l10n.dart';

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: customAppBar(context, l.contactUs),
      body: SingleChildScrollView(
        padding: 24.pa,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: 18.5.psh,
              child:
                  Text(l.contactUs, style: AppStyles.styleSemiBold18(context)),
            ),
            10.sbh,
            Padding(
              padding: 18.5.psh,
              child: Text(
                l.findAnswerToYourProblem,
                style: AppStyles.styleRegular14(context).copyWith(
                    color:
                        isAppDarkMode() ? kDarkThirdColor : kLightThirdColor),
              ),
            ),
            24.sbh,
            _buildContainer(
              context,
              title: l.customerService,
              icon: FontAwesomeIcons.headset,
              onTap: () => router.push(AppRoutes.contactUs2),
            ),
            _buildContainer(
              context,
              title: l.facebook,
              icon: Icons.facebook_outlined,
            ),
            _buildContainer(
              context,
              title: l.instagram,
              icon: FontAwesomeIcons.instagram,
            ),
            _buildContainer(
              context,
              title: l.website,
              icon: Icons.language_outlined,
            ),
            _buildContainer(
              context,
              title: l.whatsApp,
              icon: FontAwesomeIcons.whatsapp,
            ),
            _buildContainer(
              context,
              title: l.twitter,
              icon: FontAwesomeIcons.twitter,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer(BuildContext context,
      {required String title, required IconData icon, void Function()? onTap}) {
    return Padding(
      padding: 16.pb,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap ?? () {},
        child: Container(
          padding: 24.pa,
          decoration: BoxDecoration(
            color: isAppDarkMode() ? kLightSecondColor : null,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xffBDD8FF)),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color:
                      isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor),
              16.sbw,
              Text(
                title,
                style: AppStyles.styleSemiBold16(context).copyWith(
                    color:
                        isAppDarkMode() ? kDarkSecondColor : kLightSecondColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}
