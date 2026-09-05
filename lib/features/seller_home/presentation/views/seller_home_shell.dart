import 'package:flutter/material.dart';

import '../../../../core/function/components.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../seller_catalog/presentation/views/offers_tab.dart';
import '../../../seller_finance/presentation/views/finance_tab.dart';
import '../../../seller_orders/presentation/views/orders_tab.dart';
import '../../../seller_returns/presentation/views/returns_tab.dart';
import 'dashboard_tab.dart';

/// The store's main shell once activation is done.
///
/// Tabs are kept alive in an [IndexedStack] rather than rebuilt on every
/// switch: each one owns cubits that fetch on creation, and rebuilding would
/// re-hit the API every time the store glanced at another tab.
class SellerHomeShell extends StatefulWidget {
  const SellerHomeShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<SellerHomeShell> createState() => _SellerHomeShellState();
}

class _SellerHomeShellState extends State<SellerHomeShell> {
  late int _index = widget.initialIndex;

  static const List<_ShellTab> _tabs = <_ShellTab>[
    _ShellTab('Beranda', Icons.home_outlined, Icons.home_rounded),
    _ShellTab('Pesanan', Icons.receipt_long_outlined, Icons.receipt_long),
    _ShellTab('Produk', Icons.inventory_2_outlined, Icons.inventory_2),
    _ShellTab('Purna jual', Icons.assignment_return_outlined,
        Icons.assignment_return),
    _ShellTab('Keuangan', Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = isAppDarkMode();

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const <Widget>[
            DashboardTab(),
            OrdersTab(),
            OffersTab(),
            ReturnsTab(),
            FinanceTab(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        backgroundColor: isDark ? kDarkColor : kWhiteColor,
        indicatorColor:
            (isDark ? kDarkPrimaryColor : kLightPrimaryColor).withValues(
          alpha: 0.12,
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppStyles.styleMedium10(context).copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
        destinations: _tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(
                  tab.selectedIcon,
                  color: isDark ? kDarkPrimaryColor : kLightPrimaryColor,
                ),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
