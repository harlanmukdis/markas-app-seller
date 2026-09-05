# Shopapay

## Overview

This is a comprehensive e-commerce application built with Flutter. It provides a seamless shopping
experience for users, enabling them to browse products, add items to their cart, and make secure
purchases. The app also includes features for managing orders, tracking deliveries, and user
authentication.

## Thank You for Your Purchase!

We sincerely thank you for purchasing our Flutter UI kit. Your support enables us to continue
developing high-quality products and providing excellent service. We hope this UI kit helps you
build amazing applications efficiently. If you have any questions or need assistance, please
don't hesitate to contact our support team.

## How to Get and Run the App

Follow these steps to set up and run the e-commerce app on your local machine:

### Prerequisites

1. Ensure you have Flutter installed on your system. Follow the installation guide
   at Flutter.dev (https://flutter.dev/docs/get-started/install).
2. Install an editor like VS Code (https://code.visualstudio.com/)
   or Android Studio (https://developer.android.com/studio).
3. Set up an Android emulator or connect a physical device.

### Steps to Get and Run the App

1. Clone the repository
2. Navigate to the project directory
3. Fetch the dependencies by running "flutter pub get"
4. Run the app on your connected device or emulator by running "flutter run"

## How to Add a New Language to the App:

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
   Run the "flutter pub run intl_utils:generate" command in your terminal to regenerate the
   localization files.

4. Add LanguageModel
   Add a new LanguageModel to the supportedLanguages list in language_model.dart.

5. Test the New Language
   You can change the app's language to the new language and see the translations in the app
   by change it from settings page.