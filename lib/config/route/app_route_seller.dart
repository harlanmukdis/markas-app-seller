import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_routes.dart';
import '../../features/seller_auth/presentation/views/seller_login_view.dart';
import '../../features/seller_auth/presentation/views/seller_register_view.dart';
import '../../features/seller_home/presentation/views/seller_home_shell.dart';
import '../../features/seller_shell/presentation/views/seller_bootstrap_view.dart';
import '../../features/seller_store/presentation/views/store_create_view.dart';
import '../../features/seller_store/presentation/views/store_picker_view.dart';

/// Paths for the seller domain.
///
/// Kept separate from the UI kit's [AppRoutes] and spread into the single
/// [router] — the per-domain split the target architecture asks for.
abstract class SellerRoutes {
  static const String bootstrap = '/';
  static const String login = '/seller/login';
  static const String register = '/seller/register';

  /// The main shell once an account has a store selected.
  static const String home = '/seller/home';

  /// An account can own several stores, so which one the app is acting as is
  /// an explicit choice rather than an identity baked into the token.
  static const String storePicker = '/seller/stores';
  static const String storeCreate = '/seller/stores/new';
}

/// Every route uses the same fade-through wrapper as the rest of the app.
final List<RouteBase> appRouterSeller = <RouteBase>[
  _sellerRoute(SellerRoutes.bootstrap, const SellerBootstrapView()),
  _sellerRoute(SellerRoutes.login, const SellerLoginView()),
  _sellerRoute(SellerRoutes.register, const SellerRegisterView()),
  _sellerRoute(SellerRoutes.home, const SellerHomeShell()),
  _sellerRoute(SellerRoutes.storePicker, const StorePickerView()),
  _sellerRoute(SellerRoutes.storeCreate, const StoreCreateView()),
];

GoRoute _sellerRoute(String path, Widget page) => GoRoute(
      path: path,
      pageBuilder: (context, state) => FadeThroughTransitionPageWrapper(
        transitionKey: state.pageKey,
        page: page,
      ),
    );
