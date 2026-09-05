import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'core/utils/app_routes.dart';
import 'core/utils/app_theme.dart';
import 'core/utils/bloc_observer.dart';
import 'core/utils/constant.dart';
import 'core/utils/local_network.dart';
import 'core/utils/localizations.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CachedHelper.init();
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp.router(
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        title: 'Markas Seller',
        theme:
            CachedHelper.getData(kAppTheme) == kDark ? darkTheme : lightTheme,
        locale: Locale(CachedHelper.getData(kAppLanguage)),
        localeResolutionCallback: localResolutionCallback,
        localizationsDelegates: localizationsDelegates(),
        supportedLocales: S.delegate.supportedLocales,
        routerConfig: router,
      ),
    );
  }
}
