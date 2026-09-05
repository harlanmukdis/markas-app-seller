// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Stay Ahead of the Latest Trends`
  String get stayAheadTitle {
    return Intl.message(
      'Stay Ahead of the Latest Trends',
      name: 'stayAheadTitle',
      desc: '',
      args: [],
    );
  }

  /// `Be the first to discover and own the hottest fashion, tech, and lifestyle products`
  String get stayAheadSubtitle {
    return Intl.message(
      'Be the first to discover and own the hottest fashion, tech, and lifestyle products',
      name: 'stayAheadSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Effortless Shopping Experience`
  String get effortlessShoppingTitle {
    return Intl.message(
      'Effortless Shopping Experience',
      name: 'effortlessShoppingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enjoy a seamless and intuitive interface that makes shopping a breeze.`
  String get effortlessShoppingSubtitle {
    return Intl.message(
      'Enjoy a seamless and intuitive interface that makes shopping a breeze.',
      name: 'effortlessShoppingSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Discover Endless Shopping Possibilities`
  String get discoverPossibilitiesTitle {
    return Intl.message(
      'Discover Endless Shopping Possibilities',
      name: 'discoverPossibilitiesTitle',
      desc: '',
      args: [],
    );
  }

  /// `Explore a vast collection of products from top brands, all in one place.`
  String get discoverPossibilitiesSubtitle {
    return Intl.message(
      'Explore a vast collection of products from top brands, all in one place.',
      name: 'discoverPossibilitiesSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Shopapay`
  String get appName {
    return Intl.message('Shopapay', name: 'appName', desc: '', args: []);
  }

  /// `Let's you in`
  String get letsYouIn {
    return Intl.message('Let\'s you in', name: 'letsYouIn', desc: '', args: []);
  }

  /// `Continue with Google`
  String get continueWithGoogle {
    return Intl.message(
      'Continue with Google',
      name: 'continueWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Facebook`
  String get continueWithFacebook {
    return Intl.message(
      'Continue with Facebook',
      name: 'continueWithFacebook',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Apple`
  String get continueWithApple {
    return Intl.message(
      'Continue with Apple',
      name: 'continueWithApple',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get orText {
    return Intl.message('or', name: 'orText', desc: '', args: []);
  }

  /// `Sign in with password`
  String get signInWithPassword {
    return Intl.message(
      'Sign in with password',
      name: 'signInWithPassword',
      desc: '',
      args: [],
    );
  }

  /// `Sign up`
  String get signUp {
    return Intl.message('Sign up', name: 'signUp', desc: '', args: []);
  }

  /// `Need Help?`
  String get needHelp {
    return Intl.message('Need Help?', name: 'needHelp', desc: '', args: []);
  }

  /// `Welcome Back`
  String get welcomeBack {
    return Intl.message(
      'Welcome Back',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Log in to access your personalized real estate experience`
  String get loginSubtitle {
    return Intl.message(
      'Log in to access your personalized real estate experience',
      name: 'loginSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? Log In`
  String get alreadyHaveAccount {
    return Intl.message(
      'Already have an account? Log In',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Register Your New Account!`
  String get registerTitle {
    return Intl.message(
      'Register Your New Account!',
      name: 'registerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your information below`
  String get registerSubtitle {
    return Intl.message(
      'Enter your information below',
      name: 'registerSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `By creating an account, you agree to our Terms and Condition`
  String get termsAgreement {
    return Intl.message(
      'By creating an account, you agree to our Terms and Condition',
      name: 'termsAgreement',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get createAccount {
    return Intl.message(
      'Create Account',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPassword {
    return Intl.message(
      'Reset Password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Enter your new password . Remember this time!`
  String get resetPasswordInstructions {
    return Intl.message(
      'Enter your new password . Remember this time!',
      name: 'resetPasswordInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Enter Your OTP`
  String get enterOtp {
    return Intl.message('Enter Your OTP', name: 'enterOtp', desc: '', args: []);
  }

  /// `Resend code in 55 s`
  String get resendCode {
    return Intl.message(
      'Resend code in 55 s',
      name: 'resendCode',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message('Verify', name: 'verify', desc: '', args: []);
  }

  /// `3 Item at Cart`
  String get cartItemCount {
    return Intl.message(
      '3 Item at Cart',
      name: 'cartItemCount',
      desc: '',
      args: [],
    );
  }

  /// `See All`
  String get seeAll {
    return Intl.message('See All', name: 'seeAll', desc: '', args: []);
  }

  /// `Add more items`
  String get addMoreItems {
    return Intl.message(
      'Add more items',
      name: 'addMoreItems',
      desc: '',
      args: [],
    );
  }

  /// `Promo code`
  String get promoCode {
    return Intl.message('Promo code', name: 'promoCode', desc: '', args: []);
  }

  /// `Enter Code Voucher`
  String get promoCodeHint {
    return Intl.message(
      'Enter Code Voucher',
      name: 'promoCodeHint',
      desc: '',
      args: [],
    );
  }

  /// `APPLY`
  String get apply {
    return Intl.message('APPLY', name: 'apply', desc: '', args: []);
  }

  /// `Subtotal`
  String get subtotal {
    return Intl.message('Subtotal', name: 'subtotal', desc: '', args: []);
  }

  /// `Delivery`
  String get delivery {
    return Intl.message('Delivery', name: 'delivery', desc: '', args: []);
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Trending`
  String get trending {
    return Intl.message('Trending', name: 'trending', desc: '', args: []);
  }

  /// `Favorites`
  String get favorites {
    return Intl.message('Favorites', name: 'favorites', desc: '', args: []);
  }

  /// `Cart`
  String get cart {
    return Intl.message('Cart', name: 'cart', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Profile Information`
  String get profileInformation {
    return Intl.message(
      'Profile Information',
      name: 'profileInformation',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `My favorites`
  String get myFavorites {
    return Intl.message(
      'My favorites',
      name: 'myFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Payment Methods`
  String get paymentMethods {
    return Intl.message(
      'Payment Methods',
      name: 'paymentMethods',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `About Shopapay`
  String get aboutShopapay {
    return Intl.message(
      'About Shopapay',
      name: 'aboutShopapay',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logOut {
    return Intl.message('Log Out', name: 'logOut', desc: '', args: []);
  }

  /// `Are you sure want to Log Out?`
  String get logOutConfirmation {
    return Intl.message(
      'Are you sure want to Log Out?',
      name: 'logOutConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Add card`
  String get addCard {
    return Intl.message('Add card', name: 'addCard', desc: '', args: []);
  }

  /// `Card Number`
  String get cardNumber {
    return Intl.message('Card Number', name: 'cardNumber', desc: '', args: []);
  }

  /// `Card Holder Name`
  String get cardHolderName {
    return Intl.message(
      'Card Holder Name',
      name: 'cardHolderName',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get expired {
    return Intl.message('Expired', name: 'expired', desc: '', args: []);
  }

  /// `CVV Code`
  String get cvvCode {
    return Intl.message('CVV Code', name: 'cvvCode', desc: '', args: []);
  }

  /// `Add New Card`
  String get addNewCard {
    return Intl.message('Add New Card', name: 'addNewCard', desc: '', args: []);
  }

  /// `Help Center`
  String get helpCenter {
    return Intl.message('Help Center', name: 'helpCenter', desc: '', args: []);
  }

  /// `Contact Us`
  String get contactUs {
    return Intl.message('Contact Us', name: 'contactUs', desc: '', args: []);
  }

  /// `Find answer to your problem using this app.`
  String get helpCenterSubtitle {
    return Intl.message(
      'Find answer to your problem using this app.',
      name: 'helpCenterSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Customer Service`
  String get customerService {
    return Intl.message(
      'Customer Service',
      name: 'customerService',
      desc: '',
      args: [],
    );
  }

  /// `Error 404`
  String get error404 {
    return Intl.message('Error 404', name: 'error404', desc: '', args: []);
  }

  /// `We are not online this time. Please try again later`
  String get errorMessage {
    return Intl.message(
      'We are not online this time. Please try again later',
      name: 'errorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Back to Home`
  String get backToHome {
    return Intl.message('Back to Home', name: 'backToHome', desc: '', args: []);
  }

  /// `Facebook`
  String get facebook {
    return Intl.message('Facebook', name: 'facebook', desc: '', args: []);
  }

  /// `Instagram`
  String get instagram {
    return Intl.message('Instagram', name: 'instagram', desc: '', args: []);
  }

  /// `Website`
  String get website {
    return Intl.message('Website', name: 'website', desc: '', args: []);
  }

  /// `WhatsApp`
  String get whatsApp {
    return Intl.message('WhatsApp', name: 'whatsApp', desc: '', args: []);
  }

  /// `Twitter`
  String get twitter {
    return Intl.message('Twitter', name: 'twitter', desc: '', args: []);
  }

  /// `Follow us on Social Media`
  String get followUs {
    return Intl.message(
      'Follow us on Social Media',
      name: 'followUs',
      desc: '',
      args: [],
    );
  }

  /// `Shirred Puff`
  String get shirredPuff {
    return Intl.message(
      'Shirred Puff',
      name: 'shirredPuff',
      desc: '',
      args: [],
    );
  }

  /// `Rumpled Satin`
  String get rumpledSatin {
    return Intl.message(
      'Rumpled Satin',
      name: 'rumpledSatin',
      desc: '',
      args: [],
    );
  }

  /// `Double Ruffle Knit`
  String get doubleRuffleKnit {
    return Intl.message(
      'Double Ruffle Knit',
      name: 'doubleRuffleKnit',
      desc: '',
      args: [],
    );
  }

  /// `Delivery Address`
  String get deliveryAddress {
    return Intl.message(
      'Delivery Address',
      name: 'deliveryAddress',
      desc: '',
      args: [],
    );
  }

  /// `120 Lane San Fransisco , East Falmouth MA`
  String get defaultAddress {
    return Intl.message(
      '120 Lane San Fransisco , East Falmouth MA',
      name: 'defaultAddress',
      desc: '',
      args: [],
    );
  }

  /// `Add New Address`
  String get addNewAddress {
    return Intl.message(
      'Add New Address',
      name: 'addNewAddress',
      desc: '',
      args: [],
    );
  }

  /// `Add Delivery Instruction`
  String get addDeliveryInstruction {
    return Intl.message(
      'Add Delivery Instruction',
      name: 'addDeliveryInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Recent Language`
  String get recentLanguage {
    return Intl.message(
      'Recent Language',
      name: 'recentLanguage',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Bangla`
  String get bangla {
    return Intl.message('Bangla', name: 'bangla', desc: '', args: []);
  }

  /// `All Language`
  String get allLanguage {
    return Intl.message(
      'All Language',
      name: 'allLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Russian`
  String get russian {
    return Intl.message('Russian', name: 'russian', desc: '', args: []);
  }

  /// `Korean`
  String get korean {
    return Intl.message('Korean', name: 'korean', desc: '', args: []);
  }

  /// `Spanish`
  String get spanish {
    return Intl.message('Spanish', name: 'spanish', desc: '', args: []);
  }

  /// `Turkish`
  String get turkish {
    return Intl.message('Turkish', name: 'turkish', desc: '', args: []);
  }

  /// `Germany`
  String get germany {
    return Intl.message('Germany', name: 'germany', desc: '', args: []);
  }

  /// `Italian`
  String get italian {
    return Intl.message('Italian', name: 'italian', desc: '', args: []);
  }

  /// `Polish`
  String get polish {
    return Intl.message('Polish', name: 'polish', desc: '', args: []);
  }

  /// `Allow Notifications`
  String get allowNotifications {
    return Intl.message(
      'Allow Notifications',
      name: 'allowNotifications',
      desc: '',
      args: [],
    );
  }

  /// `For daily update you will get it`
  String get allowNotificationsSubtitle {
    return Intl.message(
      'For daily update you will get it',
      name: 'allowNotificationsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Email Notifications`
  String get emailNotifications {
    return Intl.message(
      'Email Notifications',
      name: 'emailNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Order Notifications`
  String get orderNotifications {
    return Intl.message(
      'Order Notifications',
      name: 'orderNotifications',
      desc: '',
      args: [],
    );
  }

  /// `General Notifications`
  String get generalNotifications {
    return Intl.message(
      'General Notifications',
      name: 'generalNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Preferences`
  String get preferences {
    return Intl.message('Preferences', name: 'preferences', desc: '', args: []);
  }

  /// `Country`
  String get country {
    return Intl.message('Country', name: 'country', desc: '', args: []);
  }

  /// `USA`
  String get usa {
    return Intl.message('USA', name: 'usa', desc: '', args: []);
  }

  /// `Application Settings`
  String get applicationSettings {
    return Intl.message(
      'Application Settings',
      name: 'applicationSettings',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message('Dark Mode', name: 'darkMode', desc: '', args: []);
  }

  /// `Support`
  String get support {
    return Intl.message('Support', name: 'support', desc: '', args: []);
  }

  /// `Terms and conditions`
  String get termsAndConditions {
    return Intl.message(
      'Terms and conditions',
      name: 'termsAndConditions',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message('Version', name: 'version', desc: '', args: []);
  }

  /// `Woman T-shirt...`
  String get womanTShirt {
    return Intl.message(
      'Woman T-shirt...',
      name: 'womanTShirt',
      desc: '',
      args: [],
    );
  }

  /// `Showing`
  String get showing {
    return Intl.message('Showing', name: 'showing', desc: '', args: []);
  }

  /// `Items`
  String get items {
    return Intl.message('Items', name: 'items', desc: '', args: []);
  }

  /// `Sort`
  String get sort {
    return Intl.message('Sort', name: 'sort', desc: '', args: []);
  }

  /// `20% off`
  String get discount {
    return Intl.message('20% off', name: 'discount', desc: '', args: []);
  }

  /// `Ruffle Knit Top`
  String get ruffleKnitTop {
    return Intl.message(
      'Ruffle Knit Top',
      name: 'ruffleKnitTop',
      desc: '',
      args: [],
    );
  }

  /// `Space Dye Crop`
  String get spaceDyeCrop {
    return Intl.message(
      'Space Dye Crop',
      name: 'spaceDyeCrop',
      desc: '',
      args: [],
    );
  }

  /// `Solid Cotton Polo`
  String get solidCottonPolo {
    return Intl.message(
      'Solid Cotton Polo',
      name: 'solidCottonPolo',
      desc: '',
      args: [],
    );
  }

  /// `Evening Dress`
  String get eveningDress {
    return Intl.message(
      'Evening Dress',
      name: 'eveningDress',
      desc: '',
      args: [],
    );
  }

  /// `Pleat Front Top`
  String get pleatFrontTop {
    return Intl.message(
      'Pleat Front Top',
      name: 'pleatFrontTop',
      desc: '',
      args: [],
    );
  }

  /// `Cotton Hoodie`
  String get cottonHoodie {
    return Intl.message(
      'Cotton Hoodie',
      name: 'cottonHoodie',
      desc: '',
      args: [],
    );
  }

  /// `Rumpled Satin Blouse`
  String get rumpledSatinBlouse {
    return Intl.message(
      'Rumpled Satin Blouse',
      name: 'rumpledSatinBlouse',
      desc: '',
      args: [],
    );
  }

  /// `Women`
  String get women {
    return Intl.message('Women', name: 'women', desc: '', args: []);
  }

  /// `Men`
  String get men {
    return Intl.message('Men', name: 'men', desc: '', args: []);
  }

  /// `Kids`
  String get kids {
    return Intl.message('Kids', name: 'kids', desc: '', args: []);
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `T-Shirt`
  String get tShirt {
    return Intl.message('T-Shirt', name: 'tShirt', desc: '', args: []);
  }

  /// `Shoes`
  String get shoes {
    return Intl.message('Shoes', name: 'shoes', desc: '', args: []);
  }

  /// `Blazers`
  String get blazers {
    return Intl.message('Blazers', name: 'blazers', desc: '', args: []);
  }

  /// `Jasmine Top`
  String get jasmineTop {
    return Intl.message('Jasmine Top', name: 'jasmineTop', desc: '', args: []);
  }

  /// `Stretch Cotton T-Shirt`
  String get stretchCottonTShirt {
    return Intl.message(
      'Stretch Cotton T-Shirt',
      name: 'stretchCottonTShirt',
      desc: '',
      args: [],
    );
  }

  /// `Cocktail Dress`
  String get cocktailDress {
    return Intl.message(
      'Cocktail Dress',
      name: 'cocktailDress',
      desc: '',
      args: [],
    );
  }

  /// `V size level Top`
  String get vSizeLevelTop {
    return Intl.message(
      'V size level Top',
      name: 'vSizeLevelTop',
      desc: '',
      args: [],
    );
  }

  /// `Woman T-shirt`
  String get womanTShirtShort {
    return Intl.message(
      'Woman T-shirt',
      name: 'womanTShirtShort',
      desc: '',
      args: [],
    );
  }

  /// `New Fashion`
  String get newFashion {
    return Intl.message('New Fashion', name: 'newFashion', desc: '', args: []);
  }

  /// `Short Sleeve V-Neck`
  String get shortSleeveVNeck {
    return Intl.message(
      'Short Sleeve V-Neck',
      name: 'shortSleeveVNeck',
      desc: '',
      args: [],
    );
  }

  /// `Coarts`
  String get coarts {
    return Intl.message('Coarts', name: 'coarts', desc: '', args: []);
  }

  /// `Tops`
  String get tops {
    return Intl.message('Tops', name: 'tops', desc: '', args: []);
  }

  /// `B.Wow'd Wireless`
  String get bWowdWireless {
    return Intl.message(
      'B.Wow\'d Wireless',
      name: 'bWowdWireless',
      desc: '',
      args: [],
    );
  }

  /// `Hodeui`
  String get hodeui {
    return Intl.message('Hodeui', name: 'hodeui', desc: '', args: []);
  }

  /// `Write Review`
  String get writeReview {
    return Intl.message(
      'Write Review',
      name: 'writeReview',
      desc: '',
      args: [],
    );
  }

  /// `Leaf Print Guipure Lace Panel Butterfly Sleeve Blouse !`
  String get leafPrintGuipureLacePanelButterflySleeveBlouse {
    return Intl.message(
      'Leaf Print Guipure Lace Panel Butterfly Sleeve Blouse !',
      name: 'leafPrintGuipureLacePanelButterflySleeveBlouse',
      desc: '',
      args: [],
    );
  }

  /// `Whats your rate ?`
  String get whatsYourRate {
    return Intl.message(
      'Whats your rate ?',
      name: 'whatsYourRate',
      desc: '',
      args: [],
    );
  }

  /// `What can we improve ?`
  String get whatCanWeImprove {
    return Intl.message(
      'What can we improve ?',
      name: 'whatCanWeImprove',
      desc: '',
      args: [],
    );
  }

  /// `Good quality & very original product`
  String get goodQuality {
    return Intl.message(
      'Good quality & very original product',
      name: 'goodQuality',
      desc: '',
      args: [],
    );
  }

  /// `All Review`
  String get allReview {
    return Intl.message('All Review', name: 'allReview', desc: '', args: []);
  }

  /// `Its good service from, the packing nice and delivery on time …`
  String get goodService {
    return Intl.message(
      'Its good service from, the packing nice and delivery on time …',
      name: 'goodService',
      desc: '',
      args: [],
    );
  }

  /// `Patrick Radden KeefeReviewer: David Grube and Gary DeLander`
  String get patrickRaddenKeefeReviewer {
    return Intl.message(
      'Patrick Radden KeefeReviewer: David Grube and Gary DeLander',
      name: 'patrickRaddenKeefeReviewer',
      desc: '',
      args: [],
    );
  }

  /// `We apologize for the inconvenience, but this event was canceled.`
  String get eventCanceled {
    return Intl.message(
      'We apologize for the inconvenience, but this event was canceled.',
      name: 'eventCanceled',
      desc: '',
      args: [],
    );
  }

  /// `Michael LewisReviewer: Bruce Thomson and Charlie Fautin`
  String get michaelLewisReviewer {
    return Intl.message(
      'Michael LewisReviewer: Bruce Thomson and Charlie Fautin',
      name: 'michaelLewisReviewer',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Color `
  String get color {
    return Intl.message('Color ', name: 'color', desc: '', args: []);
  }

  /// `White`
  String get white {
    return Intl.message('White', name: 'white', desc: '', args: []);
  }

  /// `Style `
  String get style {
    return Intl.message('Style ', name: 'style', desc: '', args: []);
  }

  /// `Casual`
  String get casual {
    return Intl.message('Casual', name: 'casual', desc: '', args: []);
  }

  /// `Type `
  String get type {
    return Intl.message('Type ', name: 'type', desc: '', args: []);
  }

  /// `Top`
  String get top {
    return Intl.message('Top', name: 'top', desc: '', args: []);
  }

  /// `Neckline `
  String get neckline {
    return Intl.message('Neckline ', name: 'neckline', desc: '', args: []);
  }

  /// `V neck`
  String get vNeck {
    return Intl.message('V neck', name: 'vNeck', desc: '', args: []);
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `Contrast Lace`
  String get contrastLace {
    return Intl.message(
      'Contrast Lace',
      name: 'contrastLace',
      desc: '',
      args: [],
    );
  }

  /// `Sleeve Length `
  String get sleeveLength {
    return Intl.message(
      'Sleeve Length ',
      name: 'sleeveLength',
      desc: '',
      args: [],
    );
  }

  /// `Half Sleeve`
  String get halfSleeve {
    return Intl.message('Half Sleeve', name: 'halfSleeve', desc: '', args: []);
  }

  /// `Sleeve Type `
  String get sleeveType {
    return Intl.message('Sleeve Type ', name: 'sleeveType', desc: '', args: []);
  }

  /// `Flounce Sleeve`
  String get flounceSleeve {
    return Intl.message(
      'Flounce Sleeve',
      name: 'flounceSleeve',
      desc: '',
      args: [],
    );
  }

  /// `Length`
  String get length {
    return Intl.message('Length', name: 'length', desc: '', args: []);
  }

  /// `Regular`
  String get regular {
    return Intl.message('Regular', name: 'regular', desc: '', args: []);
  }

  /// `Fit Type `
  String get fitType {
    return Intl.message('Fit Type ', name: 'fitType', desc: '', args: []);
  }

  /// `Regular Fit`
  String get regularFit {
    return Intl.message('Regular Fit', name: 'regularFit', desc: '', args: []);
  }

  /// `Fabric`
  String get fabric {
    return Intl.message('Fabric', name: 'fabric', desc: '', args: []);
  }

  /// `Non-Stretch`
  String get nonStretch {
    return Intl.message('Non-Stretch', name: 'nonStretch', desc: '', args: []);
  }

  /// `Material`
  String get material {
    return Intl.message('Material', name: 'material', desc: '', args: []);
  }

  /// `Woven Fabric`
  String get wovenFabric {
    return Intl.message(
      'Woven Fabric',
      name: 'wovenFabric',
      desc: '',
      args: [],
    );
  }

  /// `Composition `
  String get composition {
    return Intl.message(
      'Composition ',
      name: 'composition',
      desc: '',
      args: [],
    );
  }

  /// `100% Polyester`
  String get polyester {
    return Intl.message(
      '100% Polyester',
      name: 'polyester',
      desc: '',
      args: [],
    );
  }

  /// `Care Instructions `
  String get careInstructions {
    return Intl.message(
      'Care Instructions ',
      name: 'careInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Machine wash or professional dry clean`
  String get machineWash {
    return Intl.message(
      'Machine wash or professional dry clean',
      name: 'machineWash',
      desc: '',
      args: [],
    );
  }

  /// `Sheer`
  String get sheer {
    return Intl.message('Sheer', name: 'sheer', desc: '', args: []);
  }

  /// `Semi-Sheer`
  String get semiSheer {
    return Intl.message('Semi-Sheer', name: 'semiSheer', desc: '', args: []);
  }

  /// `Leaf Print Guipure Lace Butterfly`
  String get leafPrintGuipureLaceButterfly {
    return Intl.message(
      'Leaf Print Guipure Lace Butterfly',
      name: 'leafPrintGuipureLaceButterfly',
      desc: '',
      args: [],
    );
  }

  /// `SEE REVIEW`
  String get seeReview {
    return Intl.message('SEE REVIEW', name: 'seeReview', desc: '', args: []);
  }

  /// `Size`
  String get size {
    return Intl.message('Size', name: 'size', desc: '', args: []);
  }

  /// `S`
  String get s {
    return Intl.message('S', name: 's', desc: '', args: []);
  }

  /// `M`
  String get m {
    return Intl.message('M', name: 'm', desc: '', args: []);
  }

  /// `L`
  String get l {
    return Intl.message('L', name: 'l', desc: '', args: []);
  }

  /// `See Description`
  String get seeDescription {
    return Intl.message(
      'See Description',
      name: 'seeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Related Product`
  String get relatedProduct {
    return Intl.message(
      'Related Product',
      name: 'relatedProduct',
      desc: '',
      args: [],
    );
  }

  /// `Add to Cart`
  String get addToCart {
    return Intl.message('Add to Cart', name: 'addToCart', desc: '', args: []);
  }

  /// `Buy Now`
  String get buyNow {
    return Intl.message('Buy Now', name: 'buyNow', desc: '', args: []);
  }

  /// `Leaf Print Guipure Lace Butterfly`
  String get leafPrintGuipureLaceButterflyShort {
    return Intl.message(
      'Leaf Print Guipure Lace Butterfly',
      name: 'leafPrintGuipureLaceButterflyShort',
      desc: '',
      args: [],
    );
  }

  /// `Classical Sm Top’s`
  String get classicalSmTops {
    return Intl.message(
      'Classical Sm Top’s',
      name: 'classicalSmTops',
      desc: '',
      args: [],
    );
  }

  /// `Milo Leather Coats`
  String get miloLeatherCoats {
    return Intl.message(
      'Milo Leather Coats',
      name: 'miloLeatherCoats',
      desc: '',
      args: [],
    );
  }

  /// `Hello, mahmoud 👋`
  String get helloMahmoud {
    return Intl.message(
      'Hello, mahmoud 👋',
      name: 'helloMahmoud',
      desc: '',
      args: [],
    );
  }

  /// `Let’s explore what’s new today!`
  String get letsExplore {
    return Intl.message(
      'Let’s explore what’s new today!',
      name: 'letsExplore',
      desc: '',
      args: [],
    );
  }

  /// `My Cart`
  String get myCart {
    return Intl.message('My Cart', name: 'myCart', desc: '', args: []);
  }

  /// `New Offers`
  String get newOffers {
    return Intl.message('New Offers', name: 'newOffers', desc: '', args: []);
  }

  /// `Friday Sale`
  String get fridaySale {
    return Intl.message('Friday Sale', name: 'fridaySale', desc: '', args: []);
  }

  /// `New Macbook\nPro M1 2022`
  String get newMacbookPro {
    return Intl.message(
      'New Macbook\nPro M1 2022',
      name: 'newMacbookPro',
      desc: '',
      args: [],
    );
  }

  /// `UP TO 30% OFF`
  String get upTo30Off {
    return Intl.message('UP TO 30% OFF', name: 'upTo30Off', desc: '', args: []);
  }

  /// `Bacome Seller`
  String get becomeSeller {
    return Intl.message(
      'Bacome Seller',
      name: 'becomeSeller',
      desc: '',
      args: [],
    );
  }

  /// `END OF SEASON`
  String get endOfSeason {
    return Intl.message(
      'END OF SEASON',
      name: 'endOfSeason',
      desc: '',
      args: [],
    );
  }

  /// `GET NOW`
  String get getNow {
    return Intl.message('GET NOW', name: 'getNow', desc: '', args: []);
  }

  /// `Crewneck Tech T-Shirt`
  String get crewneckTechTShirt {
    return Intl.message(
      'Crewneck Tech T-Shirt',
      name: 'crewneckTechTShirt',
      desc: '',
      args: [],
    );
  }

  /// `How Can We Help You?`
  String get howCanWeHelpYou {
    return Intl.message(
      'How Can We Help You?',
      name: 'howCanWeHelpYou',
      desc: '',
      args: [],
    );
  }

  /// `Type here`
  String get typeHere {
    return Intl.message('Type here', name: 'typeHere', desc: '', args: []);
  }

  /// `How do I|`
  String get howDoI {
    return Intl.message('How do I|', name: 'howDoI', desc: '', args: []);
  }

  /// `How do I create an account?`
  String get howDoICreateAccount {
    return Intl.message(
      'How do I create an account?',
      name: 'howDoICreateAccount',
      desc: '',
      args: [],
    );
  }

  /// `How do I search for a product?`
  String get howDoISearchProduct {
    return Intl.message(
      'How do I search for a product?',
      name: 'howDoISearchProduct',
      desc: '',
      args: [],
    );
  }

  /// `How do I track my order?`
  String get howDoITrackOrder {
    return Intl.message(
      'How do I track my order?',
      name: 'howDoITrackOrder',
      desc: '',
      args: [],
    );
  }

  /// `How do I contact customer support?`
  String get howDoIContactSupport {
    return Intl.message(
      'How do I contact customer support?',
      name: 'howDoIContactSupport',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `How do I search for properties on the app?`
  String get howDoISearchProperties {
    return Intl.message(
      'How do I search for properties on the app?',
      name: 'howDoISearchProperties',
      desc: '',
      args: [],
    );
  }

  /// `Can I save my favorite properties on the app?`
  String get canISaveFavoriteProperties {
    return Intl.message(
      'Can I save my favorite properties on the app?',
      name: 'canISaveFavoriteProperties',
      desc: '',
      args: [],
    );
  }

  /// `Yes, most real estate apps allow you to save properties that you're interested in so that you can easily find\nthem later.`
  String get savePropertiesAnswer {
    return Intl.message(
      'Yes, most real estate apps allow you to save properties that you\'re interested in so that you can easily find\nthem later.',
      name: 'savePropertiesAnswer',
      desc: '',
      args: [],
    );
  }

  /// `How do I search for Women skart for home menu?`
  String get howDoISearchWomenSkart {
    return Intl.message(
      'How do I search for Women skart for home menu?',
      name: 'howDoISearchWomenSkart',
      desc: '',
      args: [],
    );
  }

  /// `Can i edit my profile email with my contact number?`
  String get canIEditProfileEmail {
    return Intl.message(
      'Can i edit my profile email with my contact number?',
      name: 'canIEditProfileEmail',
      desc: '',
      args: [],
    );
  }

  /// `What is the best way payment method for buy cloth?`
  String get bestPaymentMethod {
    return Intl.message(
      'What is the best way payment method for buy cloth?',
      name: 'bestPaymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `The place doesn’t exist`
  String get placeDoesntExist {
    return Intl.message(
      'The place doesn’t exist',
      name: 'placeDoesntExist',
      desc: '',
      args: [],
    );
  }

  /// `No results Found`
  String get noResultsFound {
    return Intl.message(
      'No results Found',
      name: 'noResultsFound',
      desc: '',
      args: [],
    );
  }

  /// `Checkout`
  String get checkout {
    return Intl.message('Checkout', name: 'checkout', desc: '', args: []);
  }

  /// `Payment Method`
  String get paymentMethod {
    return Intl.message(
      'Payment Method',
      name: 'paymentMethod',
      desc: '',
      args: [],
    );
  }

  /// `List of all credit cards you saved`
  String get savedCreditCards {
    return Intl.message(
      'List of all credit cards you saved',
      name: 'savedCreditCards',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get getStarted {
    return Intl.message('Get Started', name: 'getStarted', desc: '', args: []);
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Don't have an account?`
  String get dontHaveAccount {
    return Intl.message(
      'Don\'t have an account?',
      name: 'dontHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Log in to access your personalized real estate experience'`
  String get logInToAccessYourPersonalized {
    return Intl.message(
      'Log in to access your personalized real estate experience\'',
      name: 'logInToAccessYourPersonalized',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Enter your Name`
  String get enterYourName {
    return Intl.message(
      'Enter your Name',
      name: 'enterYourName',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get or {
    return Intl.message('or', name: 'or', desc: '', args: []);
  }

  /// `Email Address`
  String get email {
    return Intl.message('Email Address', name: 'email', desc: '', args: []);
  }

  /// `Enter your Email`
  String get enterYourEmail {
    return Intl.message(
      'Enter your Email',
      name: 'enterYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Remember Me`
  String get rememberMe {
    return Intl.message('Remember Me', name: 'rememberMe', desc: '', args: []);
  }

  /// `Forget Password?`
  String get forgetPassword {
    return Intl.message(
      'Forget Password?',
      name: 'forgetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continuee {
    return Intl.message('Continue', name: 'continuee', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Enter your Email then we will send you OTP to reset new password.`
  String get enterYourEmailThenWeWillSendYouOTP {
    return Intl.message(
      'Enter your Email then we will send you OTP to reset new password.',
      name: 'enterYourEmailThenWeWillSendYouOTP',
      desc: '',
      args: [],
    );
  }

  /// `Please Wait`
  String get pleaseWait {
    return Intl.message('Please Wait', name: 'pleaseWait', desc: '', args: []);
  }

  /// `Enter your naw password , Remember this time!`
  String get enterYourNawPasswordRememberThisTime {
    return Intl.message(
      'Enter your naw password , Remember this time!',
      name: 'enterYourNawPasswordRememberThisTime',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Register Your New Account`
  String get registerYourNewAccount {
    return Intl.message(
      'Register Your New Account',
      name: 'registerYourNewAccount',
      desc: '',
      args: [],
    );
  }

  /// `Enter your information below`
  String get enterYourInformationBelow {
    return Intl.message(
      'Enter your information below',
      name: 'enterYourInformationBelow',
      desc: '',
      args: [],
    );
  }

  /// `By creating an account, you agree to our `
  String get byCreatingAccountYouAgreeToOur {
    return Intl.message(
      'By creating an account, you agree to our ',
      name: 'byCreatingAccountYouAgreeToOur',
      desc: '',
      args: [],
    );
  }

  /// `SubTitle`
  String get subTitle {
    return Intl.message('SubTitle', name: 'subTitle', desc: '', args: []);
  }

  /// `Reviews`
  String get reviews {
    return Intl.message('Reviews', name: 'reviews', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Are you sure you want to log out?`
  String get areYouSureYouWantToLogOut {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'areYouSureYouWantToLogOut',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get messages {
    return Intl.message('Messages', name: 'messages', desc: '', args: []);
  }

  /// `Recent Notifications`
  String get recentNotifications {
    return Intl.message(
      'Recent Notifications',
      name: 'recentNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Clear All`
  String get clearAll {
    return Intl.message('Clear All', name: 'clearAll', desc: '', args: []);
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `Yesterday`
  String get yesterday {
    return Intl.message('Yesterday', name: 'yesterday', desc: '', args: []);
  }

  /// `Online`
  String get online {
    return Intl.message('Online', name: 'online', desc: '', args: []);
  }

  /// `Write a reply`
  String get writeReply {
    return Intl.message(
      'Write a reply',
      name: 'writeReply',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Location`
  String get unknownLocation {
    return Intl.message(
      'Unknown Location',
      name: 'unknownLocation',
      desc: '',
      args: [],
    );
  }

  /// `Unable to get current location`
  String get unableToGetCurrentLocation {
    return Intl.message(
      'Unable to get current location',
      name: 'unableToGetCurrentLocation',
      desc: '',
      args: [],
    );
  }

  /// `Add Address`
  String get addAddress {
    return Intl.message('Add Address', name: 'addAddress', desc: '', args: []);
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `List of all credit cards you saved`
  String get listOfAllCreditCardsYouSaved {
    return Intl.message(
      'List of all credit cards you saved',
      name: 'listOfAllCreditCardsYouSaved',
      desc: '',
      args: [],
    );
  }

  /// `Enter Code Voucher`
  String get enterCodeVoucher {
    return Intl.message(
      'Enter Code Voucher',
      name: 'enterCodeVoucher',
      desc: '',
      args: [],
    );
  }

  /// `Map Location`
  String get mapLocation {
    return Intl.message(
      'Map Location',
      name: 'mapLocation',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Item at Cart`
  String get itemAtCart {
    return Intl.message('Item at Cart', name: 'itemAtCart', desc: '', args: []);
  }

  /// `Your Cart is Empty`
  String get yourCartIsEmpty {
    return Intl.message(
      'Your Cart is Empty',
      name: 'yourCartIsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message('General', name: 'general', desc: '', args: []);
  }

  /// `Home Search`
  String get homeSearch {
    return Intl.message('Home Search', name: 'homeSearch', desc: '', args: []);
  }

  /// `Rate Us`
  String get rateUs {
    return Intl.message('Rate Us', name: 'rateUs', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `PayPal`
  String get payPal {
    return Intl.message('PayPal', name: 'payPal', desc: '', args: []);
  }

  /// `Master Card`
  String get masterCard {
    return Intl.message('Master Card', name: 'masterCard', desc: '', args: []);
  }

  /// `OTP Verification`
  String get otpVerification {
    return Intl.message(
      'OTP Verification',
      name: 'otpVerification',
      desc: '',
      args: [],
    );
  }

  /// `Enter Your OTP`
  String get enterYourOtp {
    return Intl.message(
      'Enter Your OTP',
      name: 'enterYourOtp',
      desc: '',
      args: [],
    );
  }

  /// `Code has sent to`
  String get codeHasSentTo {
    return Intl.message(
      'Code has sent to',
      name: 'codeHasSentTo',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Yes, most real estate apps allow you to save properties that you're interested in so that you can easily find them later.`
  String get mostRealEstateApps {
    return Intl.message(
      'Yes, most real estate apps allow you to save properties that you\'re interested in so that you can easily find them later.',
      name: 'mostRealEstateApps',
      desc: '',
      args: [],
    );
  }

  /// `To reset your password, please select contact details`
  String get toResetYourPassword {
    return Intl.message(
      'To reset your password, please select contact details',
      name: 'toResetYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Via Phone`
  String get viaPhone {
    return Intl.message('Via Phone', name: 'viaPhone', desc: '', args: []);
  }

  /// `Via Email`
  String get viaEmail {
    return Intl.message('Via Email', name: 'viaEmail', desc: '', args: []);
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `Enter your Address`
  String get enterYourAddress {
    return Intl.message(
      'Enter your Address',
      name: 'enterYourAddress',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Create New Password`
  String get createNewPassword {
    return Intl.message(
      'Create New Password',
      name: 'createNewPassword',
      desc: '',
      args: [],
    );
  }

  /// `Find answer to your problem using this app.`
  String get findAnswerToYourProblem {
    return Intl.message(
      'Find answer to your problem using this app.',
      name: 'findAnswerToYourProblem',
      desc: '',
      args: [],
    );
  }

  /// `Enter your Card`
  String get enterYourCard {
    return Intl.message(
      'Enter your Card',
      name: 'enterYourCard',
      desc: '',
      args: [],
    );
  }

  /// `Enter Holder Name`
  String get enterHolderName {
    return Intl.message(
      'Enter Holder Name',
      name: 'enterHolderName',
      desc: '',
      args: [],
    );
  }

  /// `Code`
  String get code {
    return Intl.message('Code', name: 'code', desc: '', args: []);
  }

  /// `Job Vacancy`
  String get jobVacancy {
    return Intl.message('Job Vacancy', name: 'jobVacancy', desc: '', args: []);
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Accessibility`
  String get accessibility {
    return Intl.message(
      'Accessibility',
      name: 'accessibility',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `Arabic`
  String get arabic {
    return Intl.message('Arabic', name: 'arabic', desc: '', args: []);
  }

  /// `Not Available`
  String get notAvailable {
    return Intl.message(
      'Not Available',
      name: 'notAvailable',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
