import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import '../../features/shared/models/language_model.dart';
import '../utils/constant.dart';
import '../utils/local_network.dart';

/// App Language Manager

/// Check if the app's current language is an RTL language
bool isLanguageRTL() {
  final currentLanguageCode = CachedHelper.getData(kAppLanguage) ?? 'en';
  final language = supportedLanguages.firstWhere(
    (lang) => lang.langCode == currentLanguageCode,
    orElse: () => supportedLanguages.first,
  );
  return language.direction == TextDirection.rtl;
}

bool isAppArabic() {
  return CachedHelper.getData(kAppLanguage) == 'ar';
}

/// Change the app's language and restart
Future<void> changeAppLanguage(BuildContext context, String langCode) async {
  await _updatePreferenceAndRestart(context, kAppLanguage, langCode);
}

/// App Theme Manager

/// Check if the app is in dark mode
bool isAppDarkMode() => CachedHelper.getData(kAppTheme) == kDark;

/// Toggle the app theme between light and dark mode
Future<void> toggleAppTheme(BuildContext context) async {
  final currentTheme = CachedHelper.getData(kAppTheme) ?? kLight;
  final newTheme = currentTheme == kDark ? kLight : kDark;

  await _updatePreferenceAndRestart(context, kAppTheme, newTheme);
}

/// Helper Function

/// Save a preference and restart the app
Future<void> _updatePreferenceAndRestart(
    BuildContext context, String key, dynamic value) async {
  await CachedHelper.saveData(key, value);
  if (context.mounted) {
    Phoenix.rebirth(context);
  }
}
