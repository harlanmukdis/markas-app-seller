/// Path constants, relative to [AppConfig.apiBaseUrl].
///
/// The marketplace API splits cleanly in two: paths under `/me` and `/auth`
/// belong to the logged-in **user**, and paths under `/stores/{id}` belong to
/// one of the **stores** that user owns. A user may own several, so nothing
/// here assumes a single store identity the way the previous backend did —
/// the active store id is passed explicitly and also travels as `X-Store-Id`.
abstract class ApiEndpoints {
  // ---------------------------------------------------------------- Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // ---------------------------------------------------------------- User
  static const String me = '/me';
  static const String switchRole = '/me/switch-role';
  static const String addresses = '/me/addresses';
  static String address(int id) => '/me/addresses/$id';

  /// The upload endpoint the previous backend never had. Everything that used
  /// to demand a URL the app could not produce — verification documents,
  /// product images, avatars — goes through here first.
  static const String mediaUpload = '/media/upload';

  // --------------------------------------------------------------- Store
  static const String stores = '/stores';
  static String store(int storeId) => '/stores/$storeId';
  static String storeSettings(int storeId) => '/stores/$storeId/settings';
  static String storeRatings(int storeId) => '/stores/$storeId/ratings';
  static String storeAnalytics(int storeId) => '/stores/$storeId/analytics';

  // -------------------------------------------------- Seller verification
  static String verification(int storeId) => '/stores/$storeId/verification';
  static String verificationDocuments(int storeId) =>
      '/stores/$storeId/verification/documents';

  // ------------------------------------------------------------- Catalog
  static const String categories = '/categories';
  static const String products = '/products';
  static String storeProducts(int storeId) => '/stores/$storeId/products';
  static String product(int productId) => '/products/$productId';
  static String productVariants(int productId) => '/products/$productId/variants';
  static String productVariant(int productId, int variantId) =>
      '/products/$productId/variants/$variantId';
  static String productImages(int productId) => '/products/$productId/images';

  // --------------------------------------------- Warehouses & inventory
  static String storeWarehouses(int storeId) => '/stores/$storeId/warehouses';
  static String warehouse(int warehouseId) => '/warehouses/$warehouseId';
  static String warehouseStocks(int warehouseId) =>
      '/warehouses/$warehouseId/stocks';
  static String warehouseMovements(int warehouseId) =>
      '/warehouses/$warehouseId/movements';
  static String warehouseStockIn(int warehouseId) =>
      '/warehouses/$warehouseId/stock-in';
  static String warehouseStockOut(int warehouseId) =>
      '/warehouses/$warehouseId/stock-out';
  static const String stockAdjustments = '/stock-adjustments';
  static const String stockTransfers = '/stock-transfers';
  static String stockTransferComplete(int transferId) =>
      '/stock-transfers/$transferId/complete';

  // --------------------------------------------------------------- Orders
  static String storeOrders(int storeId) => '/stores/$storeId/orders';
  static String order(int orderId) => '/orders/$orderId';
  static String orderAccept(int orderId) => '/orders/$orderId/accept';
  static String orderPack(int orderId) => '/orders/$orderId/pack';
  static String orderShip(int orderId) => '/orders/$orderId/ship';
  static String orderCancel(int orderId) => '/orders/$orderId/cancel';
  static String orderTracking(int orderId) => '/orders/$orderId/tracking';
  static String refundApprove(int orderId, int refundId) =>
      '/orders/$orderId/refund-request/$refundId/approve';
  static String refundReject(int orderId, int refundId) =>
      '/orders/$orderId/refund-request/$refundId/reject';

  // --------------------------------------------------------------- Wallet
  static String storeWallet(int storeId) => '/stores/$storeId/wallet';
  static String storeWalletWithdraw(int storeId) =>
      '/stores/$storeId/wallet/withdraw';

  // --------------------------------------------------------------- System
  static const String health = '/health';
}
