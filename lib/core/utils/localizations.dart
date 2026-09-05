import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../generated/l10n.dart';

List<LocalizationsDelegate<dynamic>> localizationsDelegates() {
  return const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

// Use localeResolutionCallback to detect the device's language
Locale? localResolutionCallback(
    Locale? locale, Iterable<Locale> supportedLocales) {
  // Check if the device's locale is supported
  for (var supportedLocale in supportedLocales) {
    if (supportedLocale.languageCode == locale?.languageCode) {
      return supportedLocale;
    }
  }
  // If the device's locale is not supported, fallback to English
  return const Locale('en');
}
