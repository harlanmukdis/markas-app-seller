import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/local_network.dart';
import '../../../../generated/l10n.dart';
import '../../../shared/models/language_model.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: customAppBar(context, l.settings),
      body: SingleChildScrollView(
        padding: 24.psh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.sbh,
            Text(
              l.preferences,
              style: AppStyles.styleMedium14(context).copyWith(
                color:
                    isAppDarkMode() ? kDarkThirdColor : const Color(0xff646568),
              ),
            ),
            16.sbh,
            InkWell(
              onTap: () {},
              child: Row(
                children: [
                  Text(l.country, style: AppStyles.styleMedium14(context)),
                  const Spacer(),
                  Text(
                    l.usa,
                    style: AppStyles.styleMedium14(context)
                        .copyWith(color: const Color(0xff909193)),
                  ),
                  12.sbw,
                  Icon(
                      isLanguageRTL()
                          ? Icons.keyboard_arrow_left_outlined
                          : Icons.keyboard_arrow_right_outlined,
                      color: isAppDarkMode()
                          ? kDarkSecondColor
                          : kLightSecondColor),
                ],
              ),
            ),
            const Divider(height: 24, color: Color(0xffD9D9D9)),
            Row(
              children: [
                Text(
                  l.language,
                  style: AppStyles.styleMedium14(context).copyWith(
                      color: isAppDarkMode()
                          ? kDarkSecondColor
                          : kLightSecondColor),
                ),
                const Spacer(),
                DropdownButton<LanguageModel>(
                  borderRadius: BorderRadius.circular(8),
                  value: supportedLanguages.firstWhere(
                    (lang) =>
                        lang.langCode == CachedHelper.getData(kAppLanguage),
                    orElse: () => supportedLanguages.first,
                  ),
                  items: supportedLanguages.map((lang) {
                    return DropdownMenuItem(
                      value: lang,
                      child: Text(
                        lang.langName,
                        style: AppStyles.styleMedium14(context)
                            .copyWith(color: const Color(0xff909193)),
                      ),
                    );
                  }).toList(),
                  onChanged: (selectedLang) async {
                    if (selectedLang != null &&
                        CachedHelper.getData(kAppLanguage) !=
                            selectedLang.langCode) {
                      changeAppLanguage(context, selectedLang.langCode);
                    }
                  },
                  underline: const SizedBox(),
                  icon: Icon(
                    isLanguageRTL()
                        ? Icons.keyboard_arrow_left_outlined
                        : Icons.keyboard_arrow_right_outlined,
                    color:
                        isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
                  ),
                ),
              ],
            ),
            20.sbh,
            Text(
              l.applicationSettings,
              style: AppStyles.styleMedium14(context).copyWith(
                  color: isAppDarkMode()
                      ? kDarkThirdColor
                      : const Color(0xff646568)),
            ),
            16.sbh,
            Row(
              children: [
                Text(
                  l.notifications,
                  style: AppStyles.styleMedium14(context).copyWith(
                      color: isAppDarkMode()
                          ? kDarkSecondColor
                          : kLightSecondColor),
                ),
                const Spacer(),
                Switch(value: true, onChanged: (_) {}),
              ],
            ),
            const Divider(height: 4, color: Color(0xffD9D9D9)),
            Row(
              children: [
                Text(
                  l.darkMode,
                  style: AppStyles.styleMedium14(context).copyWith(
                      color: isAppDarkMode()
                          ? kDarkSecondColor
                          : kLightSecondColor),
                ),
                const Spacer(),
                Switch(
                  value: CachedHelper.getData(kAppTheme) == kDark,
                  onChanged: (_) => toggleAppTheme(context),
                ),
              ],
            ),
            20.sbh,
            Text(
              l.support,
              style: AppStyles.styleMedium14(context).copyWith(
                  color: isAppDarkMode()
                      ? kDarkThirdColor
                      : const Color(0xff646568)),
            ),
            24.sbh,
            _buildRow(
              context,
              title: l.helpCenter,
              onTap: () => router.push(AppRoutes.helpCenter),
            ),
            const Divider(height: 32, color: Color(0xffD9D9D9)),
            _buildRow(context, title: l.termsAndConditions),
            const Divider(height: 32, color: Color(0xffD9D9D9)),
            _buildRow(
              context,
              title: l.contactUs,
              onTap: () => router.push(AppRoutes.contactUs),
            ),
            const Divider(height: 32, color: Color(0xffD9D9D9)),
            _buildRow(
              context,
              title: l.aboutShopapay,
              onTap: () => router.push(AppRoutes.aboutApp),
            ),
            const Divider(height: 32, color: Color(0xffD9D9D9)),
            _buildRow(context, title: '${l.version} 4.32'),
            16.sbh,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context,
      {required String title, void Function()? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppStyles.styleMedium14(context),
          ),
          Icon(
              isLanguageRTL()
                  ? Icons.keyboard_arrow_left_outlined
                  : Icons.keyboard_arrow_right_outlined,
              color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor),
        ],
      ),
    );
  }
}
