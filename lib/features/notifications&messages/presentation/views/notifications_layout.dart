import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../../core/utils/constant.dart';
import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../generated/l10n.dart';
import 'messages_view.dart';
import 'notifications_view.dart';

class NotificationsLayout extends StatefulWidget {
  const NotificationsLayout({super.key});

  @override
  State<NotificationsLayout> createState() => _NotificationsLayoutState();
}

class _NotificationsLayoutState extends State<NotificationsLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int tabIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        tabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    List<Widget> taps = [
      Text(l.notifications),
      Text(l.messages),
    ];
    return Scaffold(
      appBar: customAppBar(context, ''),
      body: Column(
        children: [
          8.sbh,
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color:
                  isAppDarkMode() ? kLightSecondColor : const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: taps,
              onTap: (index) {
                setState(() {
                  tabIndex = index;
                });
              },
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              indicator: tabIndex == 0
                  ? BoxDecoration(
                      color: isAppDarkMode()
                          ? kDarkPrimaryColor
                          : kLightPrimaryColor,
                      borderRadius: const BorderRadiusDirectional.only(
                        topStart: Radius.circular(12),
                        bottomStart: Radius.circular(12),
                      ),
                    )
                  : BoxDecoration(
                      color: isAppDarkMode()
                          ? kDarkPrimaryColor
                          : kLightPrimaryColor,
                      borderRadius: const BorderRadiusDirectional.only(
                        topEnd: Radius.circular(12),
                        bottomEnd: Radius.circular(12),
                      ),
                    ),
              labelColor: Colors.white,
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              unselectedLabelColor:
                  isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
              unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
              labelPadding: const EdgeInsets.symmetric(vertical: 12),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                NotificationsView(),
                MessagesView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
