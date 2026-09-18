/// Path constants, relative to [AppConfig.apiBaseUrl].
///
/// The marketplace API splits cleanly in two: paths under `/me` and `/auth`
/// belong to the logged-in **user**, and paths under `/stores/{id}` belong to
/// one of the **stores** that user owns. A user may own several, so nothing
/// here assumes a single store identity the way the previous backend did —
/// the active store id is passed explicitly and also travels as `X-Store-Id`.
abstract class ApiEndpoints {
  // ---------------------------------------------------------------- Auth
  /// Takes `full_name` (not `name`), `email`, `password`, `phone`. A 409 can
  /// mean either field is taken — `EMAIL_TAKEN` and `PHONE_TAKEN` are separate
  /// codes, so the form can highlight the right one.
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  /// Verification is **not** a gate on login any more: an account sits at
  /// `status: "pending_verification"` with `email_verified: "0"` and signs in
  /// regardless. Registering still returns `dev_verification_token` in a dev
  /// build, so the app can finish the flow without a mailbox — worth doing, but
  /// no longer required before the first login.
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
  /// to demand a URL the app could not produce — store logos and banners,
  /// product and variant images, avatars — goes through here first, then the
  /// returned URL is written into the owning resource's own field.
  ///
  /// Multipart, one `file` part. The allowlist is
  /// `jpg|jpeg|png|gif|webp|pdf` at 5 MB; anything else comes back as
  /// `UPLOAD_FAILED`. The URL it answers with points at a host that does not
  /// serve — run it through `normaliseUploadUrl` before storing or showing it.
  static const String mediaUpload = '/media/upload';

  // --------------------------------------------------------------- Store
  static const String stores = '/stores';

  /// The **public** profile, and a narrower row than the one `GET /stores`
  /// hands an owner: id, name, slug, description, logo, banner, type, status,
  /// rating and `opened_at`, with no `owner_user_id` and no audit timestamps.
  static String store(int storeId) => '/stores/$storeId';

  /// Can answer `data: null` — the row is created on first write, so a store
  /// that has never saved settings (every seeded one) has none. Not an error;
  /// see `StoreService.getSettings`.
  static String storeSettings(int storeId) => '/stores/$storeId/settings';

  /// The platform's master list of couriers — `jne`, `jnt`, `sicepat` — with an
  /// `is_active` flag. The source for a picker; a store's own selection is
  /// [storeCouriers].
  static const String couriers = '/couriers';

  /// The couriers this store ships with. `GET` is public and returns only
  /// `code` and `name`; `PATCH` takes `{"courier_codes": [...]}` and is
  /// **replace-all**, so an empty array clears the lot.
  ///
  /// It is an **optional whitelist**. The backend narrows a buyer's shipping
  /// options to this list only when it is non-empty; a store that has set
  /// nothing keeps every active courier, which is the deliberate default so
  /// that stores predating the feature did not suddenly lose all options.
  /// Seeded stores start empty.
  ///
  /// One inconsistency to know about: `GET /products/{id}` builds its
  /// `couriers` array straight from this table, so an unrestricted store shows
  /// `[]` there while still shipping through everything.
  static String storeCouriers(int storeId) => '/stores/$storeId/couriers';
  static String storeRatings(int storeId) => '/stores/$storeId/ratings';
  static String storeAnalytics(int storeId) => '/stores/$storeId/analytics';

  // -------------------------------------------------- Seller verification
  static String verification(int storeId) => '/stores/$storeId/verification';

  /// Its own multipart endpoint — `file` plus a `doc_type` part — rather than a
  /// URL collected from [mediaUpload]. Narrower allowlist than the general
  /// uploader (`jpg|jpeg|png|pdf`, no gif or webp), and it answers with
  /// `{"file_url": …}` where [mediaUpload] answers `{"url": …}`. Both land on
  /// the same non-serving host and need `normaliseUploadUrl`.
  static String verificationDocuments(int storeId) =>
      '/stores/$storeId/verification/documents';

  // ------------------------------------------------------------- Catalog
  /// The category tree. **Never hardcode a category id** — the seed has been
  /// rebuilt twice during development and the ids moved each time (a leaf that
  /// was `101` became `13`), so a stored id turns into `CATEGORY_NOT_FOUND`
  /// without warning. Read the tree and let the user pick. Both level-0 parents
  /// and their children are accepted as a product's `category_id`.
  static const String categories = '/categories';

  /// Public catalogue: **active products only**, and the one list endpoint that
  /// reports `meta` (page/per_page/total, plus `facets`). A seller looking for
  /// their own drafts has to use [storeProducts] instead.
  ///
  /// Filters: `q`, `category_id`, `store_id`, `min_price`, `max_price`,
  /// `min_rating`, `city`, `province`, `courier`, and `sort_by` — one of
  /// `latest` (default), `popular`, `trending`, `price_asc`, `price_desc`,
  /// `rating`; an unrecognised value falls back to `latest` rather than
  /// erroring. `meta.facets.rating` is always present, `meta.facets.category`
  /// only when `q` is given, and **the two have different shapes**: `rating`
  /// uses an integer `count`, `category` a string `cnt`.
  ///
  /// Rows here are the `products` table plus `compare_at_price` and, when one
  /// is running, `flash_sale`. **No images, stock, variants or couriers** —
  /// those exist only on [product], so a listing screen needs placeholders
  /// rather than a detail call per card.
  ///
  /// This is also the search fallback: `/search/*` needs Elasticsearch on 9200
  /// and answers `503 SEARCH_UNAVAILABLE` without it, while `?q=` here is plain
  /// MySQL and always works.
  static const String products = '/products';

  /// The seller's own catalogue, drafts included — a bare array with no `meta`.
  static String storeProducts(int storeId) => '/stores/$storeId/products';

  /// Detail, and the one call a product page needs: it nests `variants[]`,
  /// `images[]` and `couriers[]`, and adds `stock` and `compare_at_price`.
  ///
  /// Two shapes to watch. `variant_options` arrives as a **JSON string**, not
  /// an object — read it through `asEncodedMap`. And `stock` (on the product,
  /// summed across warehouses, and again per variant) is a real **integer**
  /// while almost every sibling field is a numeric string; `asInt` reads both,
  /// so route it through the same helper rather than casting.
  ///
  /// `flash_sale` is an **optional key**, present only while a sale is running
  /// — check for its presence, do not expect `null`.
  static String product(int productId) => '/products/$productId';

  /// A product is born with one auto-generated variant (`SKU-<id>-<hash>`,
  /// `variant_options: null`, price copied from `base_price`), so posting here
  /// adds a *second* one rather than the first. Stock is tracked per variant,
  /// so a single-variant product still has to point its inventory at that
  /// generated row.
  static String productVariants(int productId) => '/products/$productId/variants';
  static String productVariant(int productId, int variantId) =>
      '/products/$productId/variants/$variantId';

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
  static String warehouseAudits(int warehouseId) =>
      '/warehouses/$warehouseId/audits';
  static String auditItems(int auditId) => '/audits/$auditId/items';
  static String auditComplete(int auditId) => '/audits/$auditId/complete';

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

  /// Rejects with `WITHDRAWAL_REJECTED` when the balance is short, which is the
  /// ordinary case for a new store.
  ///
  /// ⚠️ **Never retry this automatically.** `docs/03` says an `Idempotency-Key`
  /// header is required, but no code reads it — the only idempotency that
  /// exists is a unique column the server fills with its own UUID, so two
  /// identical requests are two withdrawals. The same applies to checkout
  /// confirm. Retry has to stay off here until the backend honours the header.
  static String storeWalletWithdraw(int storeId) =>
      '/stores/$storeId/wallet/withdraw';

  // ---------------------------------------------------------------- Staff
  static String storeStaff(int storeId) => '/stores/$storeId/staff';
  static String storeStaffInvite(int storeId) => '/stores/$storeId/staff/invite';
  static String storeStaffMember(int storeId, int staffId) =>
      '/stores/$storeId/staff/$staffId';

  /// Six roles are seeded per store on creation — `owner`, `admin`, `manager`,
  /// `customer_service`, `finance_staff`, `warehouse_staff` — each with an
  /// empty `permissions` array until one is set.
  static String storeStaffRoles(int storeId) => '/stores/$storeId/staff-roles';
  static String storeStaffRolePermissions(int storeId, int roleId) =>
      '/stores/$storeId/staff-roles/$roleId/permissions';

  // ----------------------------------------------------------- Promotions
  /// Create takes `valid_from`/`valid_until` and `min_spend` — **not**
  /// `start_at`/`end_at` or `min_purchase`. The backend reads those two date
  /// keys without a fallback, so omitting either is a 500, not a 422.
  static String storeVouchers(int storeId) => '/stores/$storeId/vouchers';

  /// Flash sales, in contrast, really do take `start_at`/`end_at`.
  static String storeFlashSales(int storeId) => '/stores/$storeId/flash-sales';
  static String flashSaleProducts(int flashSaleId) =>
      '/flash-sales/$flashSaleId/products';

  // ------------------------------------------------- Performance & tax
  /// Answers `data: null` until the nightly job assigns a tier.
  static String storeTier(int storeId) => '/stores/$storeId/tier';
  static String storeHealthScore(int storeId) => '/stores/$storeId/health-score';
  static String storeTaxProfile(int storeId) => '/stores/$storeId/tax-profile';

  // ----------------------------------------------------------- Live & chat
  static String storeLiveSessions(int storeId) => '/stores/$storeId/live-sessions';
  static String liveSession(int sessionId) => '/live-sessions/$sessionId';
  static String liveSessionStart(int sessionId) =>
      '/live-sessions/$sessionId/start';
  static String liveSessionEnd(int sessionId) => '/live-sessions/$sessionId/end';
  static String liveSessionProducts(int sessionId) =>
      '/live-sessions/$sessionId/products';

  static const String chatConversations = '/chat/conversations';
  static String chatMessages(int conversationId) =>
      '/chat/conversations/$conversationId/messages';
  static String chatRead(int conversationId) =>
      '/chat/conversations/$conversationId/read';

  /// There is no WebSocket in this build despite what the docs promise — this
  /// long-poll endpoint (`?since_id=`) is the only realtime path that exists.
  static String chatPoll(int conversationId) =>
      '/chat/conversations/$conversationId/poll';

  // -------------------------------------------------- Reviews & notifications
  static String productReviews(int productId) => '/products/$productId/reviews';
  static String reviewReply(int reviewId) => '/reviews/$reviewId/reply';

  static const String notifications = '/me/notifications';
  static String notificationRead(int notificationId) =>
      '/me/notifications/$notificationId/read';
  static const String notificationsReadAll = '/me/notifications/read-all';

  // --------------------------------------------------------------- System
  static const String health = '/health';
}
