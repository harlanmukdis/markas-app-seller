import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'config/route/app_route_seller.dart';
import 'features/seller_store/presentation/cubits/store_cubit/store_cubit.dart';
import 'core/utils/app_routes.dart';
import 'core/utils/app_theme.dart';
import 'core/utils/bloc_observer.dart';
import 'core/utils/constant.dart';
import 'core/utils/local_network.dart';
import 'core/utils/localizations.dart';
import 'di/injector.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preferences first: the whole app reads theme and language synchronously at
  // build time, and the Dio client's auth interceptor reads the stored token
  // through the same store.
  await CachedHelper.init();

  // Registration order is session store -> named Dio -> services ->
  // repositories, and it has to finish before any cubit resolves a repository.
  await initialize(
    // Fired when the refresh token is gone or rejected. Without this the store
    // would sit on a screen quietly failing every call.
    onSessionExpired: () => router.go(SellerRoutes.login),
  );

  Bloc.observer = MyBlocObserver();

  final appTheme = CachedHelper.getData(kAppTheme);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          appTheme == kDark ? Brightness.light : Brightness.dark,
    ),
  );

  // Lock device orientation to portrait mode
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    Phoenix(
      child: DevicePreview(
        enabled: kDebugMode,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Which store the account is acting as is app-level state, not screen
    // state: it decides the `X-Store-Id` on every seller-side call, and it is
    // changed from one screen and read on another. Held above the router so
    // creating a store and landing on the dashboard share one instance —
    // go_router reuses the home page, so a cubit owned by that page would
    // never reload and the new store would stay invisible.
    return BlocProvider<StoreCubit>(
      create: (_) => StoreCubit()..load(),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: MaterialApp.router(
          builder: DevicePreview.appBuilder,
          debugShowCheckedModeBanner: false,
          title: 'Marketplace Seller',
          theme:
              CachedHelper.getData(kAppTheme) == kDark ? darkTheme : lightTheme,
          locale: Locale(CachedHelper.getData(kAppLanguage)),
          localeResolutionCallback: localResolutionCallback,
          localizationsDelegates: localizationsDelegates(),
          supportedLocales: S.delegate.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
  }
}
