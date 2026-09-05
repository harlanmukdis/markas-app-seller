import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/shared/models/language_model.dart';
import 'constant.dart';

class CachedHelper {
  static late SharedPreferences sharedPref;

  /// Initialize SharedPreferences and set defaults if needed
  static Future<void> init() async {
    sharedPref = await SharedPreferences.getInstance();

    // Set default language if not already set
    if (getData(kAppLanguage) == null) {
      final defaultLanguage = supportedLanguages
          .firstWhere(
            (lang) => lang.isDefault,
            orElse: () => supportedLanguages.first,
          )
          .langCode;
      await saveData(kAppLanguage, defaultLanguage);
      Intl.defaultLocale = defaultLanguage;
    }

    // Set default theme if not already set
    if (getData(kAppTheme) == null) {
      // final String themeMode =
      //     PlatformDispatcher.instance.platformBrightness == Brightness.dark
      //         ? kDark
      //         : kLight;
      await saveData(kAppTheme, kLight);
    }
  }

  /// Get data by key
  static dynamic getData(String key) {
    return sharedPref.get(key);
  }

  /// Save data by key and value
  static Future<bool> saveData(String key, dynamic value) async {
    if (value is String) return await sharedPref.setString(key, value);
    if (value is bool) return await sharedPref.setBool(key, value);
    if (value is int) return await sharedPref.setInt(key, value);
    if (value is double) return await sharedPref.setDouble(key, value);
    if (value is List<String>) {
      return await sharedPref.setStringList(key, value);
    }

    // Throw an error if an unsupported type is used
    throw UnsupportedError('Unsupported value type');
  }

  /// Remove data by key
  static Future<bool> removeData(String key) async {
    return await sharedPref.remove(key);
  }
}
