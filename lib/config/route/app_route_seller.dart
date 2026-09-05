import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_routes.dart';
import '../../features/seller_auth/presentation/views/seller_login_view.dart';
import '../../features/seller_auth/presentation/views/seller_register_view.dart';
import '../../features/seller_onboarding/presentation/views/agreement_view.dart';
import '../../features/seller_onboarding/presentation/views/bank_account_view.dart';
import '../../features/seller_onboarding/presentation/views/kyc_upload_view.dart';
import '../../features/seller_onboarding/presentation/views/onboarding_gates_view.dart';
import '../../features/seller_onboarding/presentation/views/shipping_rate_view.dart';
import '../../features/seller_onboarding/presentation/views/warehouse_view.dart';
import '../../features/seller_shell/presentation/views/seller_bootstrap_view.dart';

/// Paths for the seller domain.
///
/// Kept separate from the UI kit's [AppRoutes] and spread into the single
/// [router] — the per-domain split the target architecture asks for, started
/// here rather than by rewriting the existing flat table.
abstract class SellerRoutes {
  static const String bootstrap = '/';
  static const String login = '/seller/login';
  static const String register = '/seller/register';
  static const String onboarding = '/seller/onboarding';
  static const String kyc = '/seller/onboarding/kyc';
  static const String bankAccount = '/seller/onboarding/bank-account';
  static const String agreement = '/seller/onboarding/agreement';
  static const String warehouse = '/seller/onboarding/warehouse';
  static const String shippingRates = '/seller/onboarding/shipping-rates';
}

/// Every route uses the same fade-through wrapper as the rest of the app.
final List<RouteBase> appRouterSeller = <RouteBase>[
  _sellerRoute(SellerRoutes.bootstrap, const SellerBootstrapView()),
  _sellerRoute(SellerRoutes.login, const SellerLoginView()),
  _sellerRoute(SellerRoutes.register, const SellerRegisterView()),
  _sellerRoute(SellerRoutes.onboarding, const OnboardingGatesView()),
  _sellerRoute(SellerRoutes.kyc, const KycUploadView()),
  _sellerRoute(SellerRoutes.bankAccount, const BankAccountView()),
  _sellerRoute(SellerRoutes.agreement, const AgreementView()),
  _sellerRoute(SellerRoutes.warehouse, const WarehouseView()),
  _sellerRoute(SellerRoutes.shippingRates, const ShippingRateView()),
];

GoRoute _sellerRoute(String path, Widget page) => GoRoute(
      path: path,
      pageBuilder: (context, state) => FadeThroughTransitionPageWrapper(
        transitionKey: state.pageKey,
        page: page,
      ),
    );
