import '../core/data/datasources/remote/service/auth_service.dart';
import '../core/data/datasources/remote/service/catalog_service.dart';
import '../core/data/datasources/remote/service/chat_service.dart';
import '../core/data/datasources/remote/service/dispute_service.dart';
import '../core/data/datasources/remote/service/finance_service.dart';
import '../core/data/datasources/remote/service/inventory_service.dart';
import '../core/data/datasources/remote/service/offer_service.dart';
import '../core/data/datasources/remote/service/order_service.dart';
import '../core/data/datasources/remote/service/report_service.dart';
import '../core/data/datasources/remote/service/returns_service.dart';
import '../core/data/datasources/remote/service/rfq_service.dart';
import '../core/data/datasources/remote/service/seller_service.dart';
import '../core/data/datasources/remote/service/shipment_service.dart';
import '../core/data/datasources/remote/service/shipping_rate_service.dart';
import '../core/data/datasources/remote/service/voucher_service.dart';
import 'injector.dart';

/// Services take the named Dio instance. Register new ones here, never in
/// [initializeRepository] — repositories are constructed from these.
void initializeService() {
  final dio = apiDio;

  injector.registerLazySingleton<AuthService>(() => AuthService(dio));
  injector.registerLazySingleton<SellerService>(() => SellerService(dio));
  injector.registerLazySingleton<ShippingRateService>(
    () => ShippingRateService(dio),
  );
  injector.registerLazySingleton<CatalogService>(() => CatalogService(dio));
  injector.registerLazySingleton<OfferService>(() => OfferService(dio));
  injector.registerLazySingleton<InventoryService>(() => InventoryService(dio));
  injector.registerLazySingleton<OrderService>(() => OrderService(dio));
  injector.registerLazySingleton<ShipmentService>(() => ShipmentService(dio));
  injector.registerLazySingleton<FinanceService>(() => FinanceService(dio));
  injector.registerLazySingleton<ReturnsService>(() => ReturnsService(dio));
  injector.registerLazySingleton<DisputeService>(() => DisputeService(dio));
  injector.registerLazySingleton<ChatService>(() => ChatService(dio));
  injector.registerLazySingleton<VoucherService>(() => VoucherService(dio));
  injector.registerLazySingleton<RfqService>(() => RfqService(dio));
  injector.registerLazySingleton<ReportService>(() => ReportService(dio));
}
