import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../generated/l10n.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: customAppBar(context, l.helpCenter),
      body: Padding(
        padding: 24.psh,
        child: Column(
          children: [
            16.sbh,
            CustomTextFormField(
              filled: true,
              hintText: l.search,
              prefix: SvgPicture.asset(
                AppImages.search,
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(
                    isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
                    BlendMode.srcIn),
              ),
            ),
            24.sbh,
            Expanded(
              child: ListView.separated(
                itemCount: 10,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: 16.pb,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        collapsedBackgroundColor: Colors.transparent,
                        backgroundColor: Colors.transparent,
                        collapsedIconColor: isAppDarkMode()
                            ? kDarkSecondColor
                            : kLightSecondColor,
                        // Collapsed icon color
                        title: Text(
                          l.howDoISearchProperties,
                          style: AppStyles.styleRegular16(context).copyWith(
                            color: isAppDarkMode()
                                ? kDarkSecondColor
                                : kLightThirdColor,
                          ),
                        ),
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            l.mostRealEstateApps,
                            style: AppStyles.styleRegular12(context).copyWith(
                              color: isAppDarkMode()
                                  ? kDarkThirdColor
                                  : kLightThirdColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
