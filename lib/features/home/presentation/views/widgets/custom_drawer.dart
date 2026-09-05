import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../../core/function/components.dart';
import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import 'custom_list_view_item_drawer_widget.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.75,
      child: Container(
        color: isAppDarkMode() ? kDarkColor : kWhiteColor,
        width: MediaQuery.sizeOf(context).width * 0.8,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Image.asset(
                      AppImages.avatar,
                      fit: BoxFit.cover,
                      width: 45,
                      height: 45,
                    ),
                    const SizedBox(
                      width: 14,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Mahmodul Hasan",
                            style: AppStyles.styleMedium14(context)),
                        4.sbh,
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "info.mahmodul@gmail.com",
                            style: AppStyles.styleRegular12(context),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: .5,
                color: const Color(0xffE8E7F1),
                width: double.infinity,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 8,
              ),
            ),
            const CustomListViewItemDrawer(),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Divider(
                    thickness: .5,
                    color: Color(0xffE8E7F1),
                    height: 32,
                  ),
                  LogoutWidget(),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
