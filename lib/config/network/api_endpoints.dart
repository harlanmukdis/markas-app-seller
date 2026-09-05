/// Path constants, relative to [AppConfig.apiBaseUrl].
///
/// Only the paths phase 1 actually calls are listed. Two routing quirks from
/// API doc 1.6 are worth remembering when this list grows: `GET /returns/{id}`
/// and `GET /disputes/{id}` do not exist — those need `/detail` — and a 404
/// reading "Endpoint not found" means the URL is wrong, while "Not found"
/// means the URL is right but the row is not yours.
abstract class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';

  // Seller profile & onboarding
  static String seller(int sellerId) => '/sellers/$sellerId';

  static String kycUpload(int sellerId) => '/sellers/$sellerId/kyc_upload';

  static String bankAccountAdd(int sellerId) =>
      '/sellers/$sellerId/bank_account_add';

  static String bankAccounts(int sellerId) =>
      '/sellers/$sellerId/bank_accounts';

  static String signAgreement(int sellerId) =>
      '/sellers/$sellerId/sign_agreement';

  static String warehouses(int sellerId) => '/sellers/$sellerId/warehouses';

  // Shipping rates (gate 3)
  static const String shippingRates = '/shipping-rates';

  static String shippingRate(int rateId) => '/shipping-rates/$rateId';

  static const String zones = '/zones';
  static const String fleetTypes = '/fleet-types';
}
