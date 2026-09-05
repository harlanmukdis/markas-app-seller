import 'package:flutter/material.dart';

class LanguageModel {
  final String langCode;
  final String langName;
  final bool isDefault;
  final TextDirection direction;

  LanguageModel({
    required this.langCode,
    required this.langName,
    this.isDefault = false,
    required this.direction,
  });
}

// List of Supported Languages
final List<LanguageModel> supportedLanguages = [
  LanguageModel(
    langCode: 'en',
    langName: 'English',
    direction: TextDirection.ltr,
    isDefault: true,
  ),
  LanguageModel(
    langCode: 'ar',
    langName: 'العربية',
    direction: TextDirection.rtl,
  ),
  // Add more languages as needed
  // LanguageModel(langCode: 'fr', langName: 'Français', direction: TextDirection.ltr),
];

///////////////////////////////////////////////////////////////////////////////////////////////////

/*

/// How to Add a New Language to the App:

1. Add the Language File
  Open the lib/l10n/ directory and add a new .arb file for the desired language.
  For example:
  intl_en.arb (for English)
  intl_ar.arb (for Arabic)

2. Define Translations
  Inside the new .arb file, add translations for all keys.
  Example:
  {
    "hello": "Hola",
    "welcome": "Bienvenido"
  }

3. Generate Localization
  Run the flutter pub run intl_utils:generate command in your terminal to regenerate the localization files.

4. Add LanguageModel
  Add a new LanguageModel to the supportedLanguages list in language_model.dart.

5. Test the New Language
  You can change the app's language to the new language and see the translations in the app
  by change it from settings page.

*/
