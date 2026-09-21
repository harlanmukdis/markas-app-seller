import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_routes.dart';
import '../../features/seller_auth/presentation/views/seller_login_view.dart';
import '../../features/seller_catalog/presentation/views/product_form_view.dart';
import '../../features/seller_chat/presentation/views/chat_inbox_view.dart';
import '../../features/seller_chat/presentation/views/chat_thread_view.dart';
import '../../features/seller_catalog/presentation/views/product_list_view.dart';
import '../../features/seller_auth/presentation/views/seller_register_view.dart';
import '../../features/seller_home/presentation/views/seller_home_shell.dart';
import '../../features/seller_inventory/presentation/views/stock_view.dart';
import '../../features/seller_orders/presentation/views/order_detail_view.dart';
import '../../features/seller_orders/presentation/views/order_list_view.dart';
import '../../features/seller_promotions/presentation/views/flash_sale_detail_view.dart';
import '../../features/seller_promotions/presentation/views/promotion_view.dart';
import '../../features/seller_inventory/presentation/views/warehouse_list_view.dart';
import '../../features/seller_shipping/presentation/views/courier_view.dart';
import '../../features/seller_verification/presentation/views/verification_view.dart';
import '../../features/seller_wallet/presentation/views/wallet_view.dart';
import '../../features/seller_shell/presentation/views/seller_bootstrap_view.dart';
import '../../features/seller_store/presentation/views/store_create_view.dart';
import '../../features/seller_store/presentation/views/store_picker_view.dart';

/// Paths for the seller domain.
///
/// Kept separate from the UI kit's [AppRoutes] and spread into the single
/// [router] — the per-domain split the target architecture asks for.
abstract class SellerRoutes {
  static const String bootstrap = '/';
  static const String login = '/seller/login';
  static const String register = '/seller/register';

  /// The main shell once an account has a store selected.
  static const String home = '/seller/home';

  /// An account can own several stores, so which one the app is acting as is
  /// an explicit choice rather than an identity baked into the token.
  static const String storePicker = '/seller/stores';
  static const String storeCreate = '/seller/stores/new';

  /// The catalogue of whichever store is active.
  static const String products = '/seller/products';
  static const String productCreate = '/seller/products/new';

  /// Declared with a path parameter rather than `state.extra`, so a product
  /// screen survives a reload and is linkable — `extra` is the kit's habit, not
  /// something the seller domain has to inherit.
  static const String productEdit = '/seller/products/:id';

  static String productEditPath(int productId) => '/seller/products/$productId';

  /// Verification is the only route out of `inactive`, so it hangs off the
  /// dashboard rather than being buried in settings.
  static const String verification = '/seller/verification';

  /// Warehouses, and the stock held in one of them.
  static const String warehouses = '/seller/warehouses';
  static const String warehouseStock = '/seller/warehouses/:id/stock';

  static String warehouseStockPath(int warehouseId) =>
      '/seller/warehouses/$warehouseId/stock';

  /// Which couriers the store ships with — an optional whitelist; picking none
  /// leaves every courier on offer.
  static const String couriers = '/seller/couriers';

  /// Incoming orders, and one of them.
  static const String orders = '/seller/orders';
  static const String orderDetail = '/seller/orders/:id';

  static String orderDetailPath(int orderId) => '/seller/orders/$orderId';

  /// Where the store's earnings land, and the only route out of them.
  static const String wallet = '/seller/wallet';

  /// Vouchers and flash sales, both create-and-list only.
  static const String promotions = '/seller/promotions';

  /// One sale's contents. There is no `GET /flash-sales/{id}` on the backend,
  /// so the screen recovers the sale from the store's list by this id.
  static const String flashSaleDetail = '/seller/flash-sales/:id';

  static String flashSaleDetailPath(int flashSaleId) =>
      '/seller/flash-sales/$flashSaleId';

  /// Chat. The inbox is not an inbox yet — the backend has no store-scoped
  /// conversation list — so it explains the gap and hands off to a thread,
  /// which does work.
  static const String chat = '/seller/chat';
  static const String chatThread = '/seller/chat/:id';

  static String chatThreadPath(int conversationId) =>
      '/seller/chat/$conversationId';
}

/// Every route uses the same fade-through wrapper as the rest of the app.
///
/// Order matters: `/seller/products/new` has to come before the greedier
/// `/seller/products/:id`, or "new" is read as a product id.
final List<RouteBase> appRouterSeller = <RouteBase>[
  _sellerRoute(SellerRoutes.bootstrap, const SellerBootstrapView()),
  _sellerRoute(SellerRoutes.login, const SellerLoginView()),
  _sellerRoute(SellerRoutes.register, const SellerRegisterView()),
  _sellerRoute(SellerRoutes.home, const SellerHomeShell()),
  _sellerRoute(SellerRoutes.storePicker, const StorePickerView()),
  _sellerRoute(SellerRoutes.storeCreate, const StoreCreateView()),
  _sellerRoute(SellerRoutes.products, const ProductListView()),
  _sellerRoute(SellerRoutes.productCreate, const ProductFormView()),
  _sellerRouteBuilder(
    SellerRoutes.productEdit,
    (state) => ProductFormView(
      productId: int.tryParse(state.pathParameters['id'] ?? ''),
    ),
  ),
  _sellerRoute(SellerRoutes.verification, const VerificationView()),
  _sellerRoute(SellerRoutes.couriers, const CourierView()),
  _sellerRoute(SellerRoutes.orders, const OrderListView()),
  _sellerRoute(SellerRoutes.wallet, const WalletView()),
  _sellerRoute(SellerRoutes.promotions, const PromotionView()),
  _sellerRoute(SellerRoutes.chat, const ChatInboxView()),
  _sellerRouteBuilder(
    SellerRoutes.chatThread,
    (state) => ChatThreadView(
      conversationId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
    ),
  ),
  _sellerRouteBuilder(
    SellerRoutes.flashSaleDetail,
    (state) => FlashSaleDetailView(
      flashSaleId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
    ),
  ),
  _sellerRouteBuilder(
    SellerRoutes.orderDetail,
    (state) => OrderDetailView(
      orderId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
    ),
  ),
  _sellerRoute(SellerRoutes.warehouses, const WarehouseListView()),
  _sellerRouteBuilder(
    SellerRoutes.warehouseStock,
    (state) => StockView(
      warehouseId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
    ),
  ),
];

GoRoute _sellerRoute(String path, Widget page) =>
    _sellerRouteBuilder(path, (_) => page);

GoRoute _sellerRouteBuilder(
  String path,
  Widget Function(GoRouterState state) builder,
) =>
    GoRoute(
      path: path,
      pageBuilder: (context, state) => FadeThroughTransitionPageWrapper(
        transitionKey: state.pageKey,
        page: builder(state),
      ),
    );
