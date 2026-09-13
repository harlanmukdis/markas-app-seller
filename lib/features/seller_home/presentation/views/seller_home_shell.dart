import 'package:flutter/material.dart';

import '../../../../core/function/components.dart';
import '../../../../core/utils/constant.dart';
import 'dashboard_tab.dart';

/// The shell the store works in.
///
/// Only the store domain has been rebuilt against the marketplace backend so
/// far, so there is one destination. Tabs come back as each domain lands —
/// products, orders, inventory, wallet — rather than sitting here as
/// placeholders that look finished and do nothing.
class SellerHomeShell extends StatefulWidget {
  const SellerHomeShell({super.key});

  @override
  State<SellerHomeShell> createState() => _SellerHomeShellState();
}

class _SellerHomeShellState extends State<SellerHomeShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isAppDarkMode() ? kDarkColor : kWhiteColor,
      body: const SafeArea(child: DashboardTab()),
    );
  }
}
