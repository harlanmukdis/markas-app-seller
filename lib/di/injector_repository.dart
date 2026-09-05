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
import '../core/data/local/session_store.dart';
import '../core/data/repositories/auth_repository_impl.dart';
import '../core/data/repositories/catalog_repository_impl.dart';
import '../core/data/repositories/chat_repository_impl.dart';
import '../core/data/repositories/dispute_repository_impl.dart';
import '../core/data/repositories/finance_repository_impl.dart';
import '../core/data/repositories/inventory_repository_impl.dart';
import '../core/data/repositories/offer_repository_impl.dart';
import '../core/data/repositories/order_repository_impl.dart';
import '../core/data/repositories/report_repository_impl.dart';
import '../core/data/repositories/returns_repository_impl.dart';
import '../core/data/repositories/rfq_repository_impl.dart';
import '../core/data/repositories/seller_repository_impl.dart';
import '../core/data/repositories/shipment_repository_impl.dart';
import '../core/data/repositories/shipping_rate_repository_impl.dart';
import '../core/data/repositories/voucher_repository_impl.dart';
import '../core/domain/repositories/auth_repository.dart';
import '../core/domain/repositories/catalog_repository.dart';
import '../core/domain/repositories/chat_repository.dart';
import '../core/domain/repositories/dispute_repository.dart';
import '../core/domain/repositories/finance_repository.dart';
import '../core/domain/repositories/inventory_repository.dart';
import '../core/domain/repositories/offer_repository.dart';
import '../core/domain/repositories/order_repository.dart';
import '../core/domain/repositories/report_repository.dart';
import '../core/domain/repositories/returns_repository.dart';
import '../core/domain/repositories/rfq_repository.dart';
import '../core/domain/repositories/seller_repository.dart';
import '../core/domain/repositories/shipment_repository.dart';
import '../core/domain/repositories/shipping_rate_repository.dart';
import '../core/domain/repositories/voucher_repository.dart';
import 'injector.dart';

/// Repositories are registered against their **abstract** type, which is what
/// cubits ask for: `injector<OrderRepository>()`.
void initializeRepository() {
  injector.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(injector<AuthService>(), injector<SessionStore>()),
  );

  injector.registerLazySingleton<SellerRepository>(
    () => SellerRepositoryImpl(
      injector<SellerService>(),
      injector<SessionStore>(),
    ),
  );

  injector.registerLazySingleton<ShippingRateRepository>(
    () => ShippingRateRepositoryImpl(injector<ShippingRateService>()),
  );

  injector.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(injector<CatalogService>()),
  );

  injector.registerLazySingleton<OfferRepository>(
    () => OfferRepositoryImpl(injector<OfferService>()),
  );

  injector.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(injector<InventoryService>()),
  );

  injector.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(injector<OrderService>()),
  );

  injector.registerLazySingleton<ShipmentRepository>(
    () => ShipmentRepositoryImpl(injector<ShipmentService>()),
  );

  injector.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(injector<FinanceService>()),
  );

  injector.registerLazySingleton<ReturnsRepository>(
    () => ReturnsRepositoryImpl(injector<ReturnsService>()),
  );

  injector.registerLazySingleton<DisputeRepository>(
    () => DisputeRepositoryImpl(injector<DisputeService>()),
  );

  injector.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(injector<ChatService>()),
  );

  injector.registerLazySingleton<VoucherRepository>(
    () => VoucherRepositoryImpl(injector<VoucherService>()),
  );

  injector.registerLazySingleton<RfqRepository>(
    () => RfqRepositoryImpl(injector<RfqService>()),
  );

  injector.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(injector<ReportService>()),
  );
}
