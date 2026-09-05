import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../../core/function/components.dart';
import '../../../../../core/function/get_responsive_font_size.dart';
import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/app_routes.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/local_network.dart';
import '../../../../../core/widgets/custom_buttons.dart';
import '../../../../../generated/l10n.dart';
import '../../../../shared/models/language_model.dart';
import '../../../data/models/custom_list_tile_model.dart';
import '../../cubits/home_page_cubit/home_page_cubit.dart';
import '../../cubits/home_page_cubit/home_page_state.dart';

class CustomListViewItemDrawer extends StatelessWidget {
  const CustomListViewItemDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final List<CustomListTitleModel> listTitleModel = [
      CustomListTitleModel(
        title: l.editProfile,
        image: AppImages.profile,
        onTap: () => router.push(AppRoutes.editProfile),
      ),
      CustomListTitleModel(
        title: l.becomeSeller,
        image: AppImages.becomeSeller,
      ),
      CustomListTitleModel(
        title: l.paymentMethods,
        image: AppImages.payment,
        onTap: () => router.push(AppRoutes.paymentMethods),
      ),
      CustomListTitleModel(
        title: l.forgetPassword,
        image: AppImages.forgotPassword,
        onTap: () => router.push(AppRoutes.forgotPassword),
      ),
      CustomListTitleModel(
        title: l.settings,
        image: AppImages.settings,
        onTap: () => router.push(AppRoutes.settings),
      ),
      CustomListTitleModel(
        title: l.language,
        image: AppImages.language,
        onTap: null,
      ),
      CustomListTitleModel(
        title: l.darkMode,
        image: AppImages.darkMode,
        onTap: () => toggleAppTheme(context),
      ),
      CustomListTitleModel(
          title: l.helpCenter,
          image: AppImages.helpCenter,
          onTap: () => router.push(AppRoutes.helpCenter)),
    ];
    return BlocConsumer<HomePageCubit, HomePageState>(
      listener: (context, state) {},
      builder: (context, state) {
        return SliverList.builder(
          itemCount: listTitleModel.length,
          itemBuilder: (BuildContext context, int index) {
            return CustomListView(listTitleModel: listTitleModel[index]);
          },
        );
      },
    );
  }
}

class CustomListView extends StatelessWidget {
  const CustomListView({
    super.key,
    required this.listTitleModel,
  });

  final CustomListTitleModel listTitleModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: 8.psh,
      child: Container(
        padding: 2.psv,
        margin: 2.pb,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isAppDarkMode() ? const Color(0xff2F2F2F) : null,
        ),
        child: ListTile(
          onTap: listTitleModel.onTap,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: SvgPicture.asset(
                  listTitleModel.image,
                  width: 24,
                  height: 24,
                  fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(
                      isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
                      BlendMode.srcIn),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                listTitleModel.title,
                style: AppStyles.styleMedium14(context).copyWith(
                    color:
                        isAppDarkMode() ? kDarkThirdColor : kLightThirdColor),
              ),
              const Spacer(),
              if (listTitleModel.title == S.of(context).language)
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
                  icon: const Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: Color(0xff909193),
                  ),
                ),
              if (listTitleModel.title == S.of(context).darkMode)
                isAppDarkMode()
                    ? Icon(
                        Icons.toggle_on_rounded,
                        size: 55,
                        color: isAppDarkMode()
                            ? kDarkPrimaryColor
                            : kLightPrimaryColor,
                      )
                    : const Icon(
                        Icons.toggle_off_rounded,
                        size: 55,
                        color: Color(0xffBDD8FF),
                      ),
            ],
          ),
          // leading: Icon(Icons.add_chart , color: Colors.white,),
        ),
      ),
    );
  }
}

class LogoutWidget extends StatelessWidget {
  const LogoutWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Padding(
      padding: 16.psh,
      child: Container(
        padding: 2.psv,
        margin: 2.pb,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isAppDarkMode() ? const Color(0xff2F2F2F) : null,
        ),
        child: ListTile(
          mouseCursor: SystemMouseCursors.click,
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
                          .copyWith(color: const Color(0xffFF0000)),
                    ),
                    onPressed: () => router.go(AppRoutes.login),
                  ),
                ],
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Transform.rotate(
                  angle: isLanguageRTL() ? pi : 0,
                  child: SvgPicture.asset(
                    AppImages.logout,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    // color: ColorManager.redLogout,
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                l.logOut,
                style: TextStyle(
                  fontSize: getResponsiveFontSize(context, fontSize: 14),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xffFF0000),
                ),
              ),
            ],
          ),
          // leading: Icon(Icons.add_chart , color: Colors.white,),
        ),
      ),
    );
  }
}
