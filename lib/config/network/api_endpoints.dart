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

  // Catalogue
  static const String categories = '/categories';

  static String category(int id) => '/categories/$id';

  /// Requires either `q` or `category_id`.
  static const String skuMaster = '/sku-master';

  static String skuMasterDetail(int id) => '/sku-master/$id';

  static const String skuRequests = '/sku-requests';

  static String skuRequestWithdraw(int id) => '/sku-requests/$id/withdraw';

  static String skuRequestResubmit(int id) => '/sku-requests/$id/resubmit';

  // Offers
  static const String offers = '/offers';

  static String offer(int id) => '/offers/$id';

  static String offerPriceTiers(int id) => '/offers/$id/price_tiers';

  static String offerGates(int id) => '/offers/$id/gates';

  static String offerActivate(int id) => '/offers/$id/activate';

  static String offerDeactivate(int id) => '/offers/$id/deactivate';

  // Inventory
  static const String inventoryStockIn = '/inventory/stock_in';
  static const String inventoryAdjust = '/inventory/adjust';
  static const String inventoryLedger = '/inventory/ledger';
  static const String inventoryAvailable = '/inventory/available';

  // Orders
  static const String orders = '/orders';

  static String order(int id) => '/orders/$id';

  static String subOrder(int id) => '/sub-orders/$id';

  static String subOrderConfirm(int id) => '/sub-orders/$id/confirm';

  static String subOrderReject(int id) => '/sub-orders/$id/reject';

  static String subOrderReadyToShip(int id) => '/sub-orders/$id/ready_to_ship';

  // Shipments
  static const String shipments = '/shipments';

  static String shipment(int id) => '/shipments/$id';

  static String shipmentProcess(int id) => '/shipments/$id/process';

  static String shipmentShip(int id) => '/shipments/$id/ship';

  static String shipmentPod(int id) => '/shipments/$id/pod';

  static String shipmentFailDelivery(int id) => '/shipments/$id/fail_delivery';

  static String shipmentReturnToSeller(int id) =>
      '/shipments/$id/return_to_seller';

  // Finance
  static const String financeBalance = '/finance/balance';
  static const String financeLedger = '/finance/ledger';
  static const String financeWithdraw = '/finance/withdraw';
  static const String financeInvoices = '/finance/invoices';
  static const String financeTaxInvoices = '/finance/tax_invoices';

  // Returns — note there is no `GET /returns/{id}`; the detail route needs
  // the `/detail` suffix (API doc 1.6).
  static const String returns = '/returns';

  static String returnDetail(int id) => '/returns/$id/detail';

  static String returnRespond(int id) => '/returns/$id/respond';

  static String returnInspect(int id) => '/returns/$id/inspect';

  // Disputes — same `/detail` quirk as returns.
  static const String disputes = '/disputes';

  static String disputeDetail(int id) => '/disputes/$id/detail';

  static String disputeEvidence(int id) => '/disputes/$id/evidence';

  // Chat
  static const String chatThreads = '/chat/threads';
  static const String chatMessages = '/chat/messages';
  static const String chatResponseRate = '/chat/seller_response_rate';

  // Vouchers
  static const String vouchers = '/vouchers';

  static String voucher(int id) => '/vouchers/$id';

  // RFQ
  static const String rfq = '/rfq';

  static String rfqDetail(int id) => '/rfq/$id';

  static String rfqOffers(int id) => '/rfq/$id/offers';

  static String rfqRequestAdjustment(int contractId) =>
      '/rfq/$contractId/request_adjustment';

  static String rfqBatches(int contractId) => '/rfq/$contractId/batches';

  static String rfqCancellationTerms(int contractId) =>
      '/rfq/$contractId/cancellation_terms';

  // Reports
  static const String reportSales = '/reports/sales';
  static const String reportStock = '/reports/stock';
  static const String reportFinanceSummary = '/reports/finance_summary';
  static const String reportSellerPerformance = '/reports/seller_performance';
  static const String reportPph22 = '/reports/pph22';

  // Config
  static const String configParameters = '/config/parameters';
}
