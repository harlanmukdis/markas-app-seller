import 'package:flutter/material.dart';

// Colors
const Color kLightPrimaryColor = Color(0xff1D55F3);
const Color kDarkPrimaryColor = Color(0xff246BFD);
const Color kLightSecondColor = Color(0xff212121);
const Color kDarkSecondColor = Color(0xffF7F7F7);
const Color kLightThirdColor = Color(0xff616161);
const Color kDarkThirdColor = Color(0xffE8E8E8);
const Color kBorderColor = Color(0xffF2F2F2);
const Color kSuccessColor = Colors.green;
const Color kWarningColor = Colors.deepOrangeAccent;
const Color kErrorColor = Colors.redAccent;
const Color kDeleteColor = Color(0xffFF3D00);
const Color kWhiteColor = Colors.white;
const Color kBlackColor = Colors.black;
const Color kDarkColor = Color(0xff2B2B2B);

// Font
const String kFontFamily = 'Hanimation';

// General
const String kAccessToken = 'accessToken';
const String kRefreshToken = 'refreshToken';
const String kUserId = 'userId';
const String kAppLanguage = 'appLanguage';
const String kAppTheme = 'appTheme';
const String kDark = 'dark';
const String kLight = 'light';

// Seller session (Markas API)
const String kSellerId = 'sellerId';
const String kUserRole = 'userRole';
const String kUserFullName = 'userFullName';
const String kUserPhone = 'userPhone';

/// Locally recorded KYC doc types, so the upload screen can show what has
/// already been sent. The backend exposes no endpoint that lists KYC documents
/// back, so this is a client-side note only — never treat it as server truth.
const String kKycSubmittedDocTypes = 'kycSubmittedDocTypes';
