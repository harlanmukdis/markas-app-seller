import 'package:flutter/material.dart';

import '../../../../config/route/app_route_seller.dart';
import '../../../../core/data/local/session_store.dart';
import '../../../../core/function/components.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../di/injector.dart';

/// The app's entry point.
///
/// Deliberately asset-free. The UI kit's animated splash renders four SVGs from
/// `assets/images/`, and that directory does not exist in this repo — so it
/// throws on every frame. This screen decides where to go and gets out of the
/// way; the original splash stays registered for when the assets are restored.
class SellerBootstrapView extends StatefulWidget {
  const SellerBootstrapView({super.key});

  @override
  State<SellerBootstrapView> createState() => _SellerBootstrapViewState();
}

class _SellerBootstrapViewState extends State<SellerBootstrapView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  void _route() {
    final session = injector<SessionStore>();

    // No token, or a token belonging to an account with no store attached —
    // every seller endpoint would answer 403 NO_SELLER_CONTEXT, so there is
    // nothing useful to show.
    if (!session.isLoggedIn || !session.hasSellerContext) {
      router.go(SellerRoutes.login);
      return;
    }

    router.go(SellerRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isAppDarkMode() ? kDarkColor : kWhiteColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Markas Seller', style: AppStyles.styleSemiBold24(context)),
            24.sbh,
            CircularProgressIndicator(
              color: isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
