import '../core/data/datasources/remote/service/auth_service.dart';
import '../core/data/datasources/remote/service/catalog_service.dart';
import '../core/data/datasources/remote/service/inventory_service.dart';
import '../core/data/datasources/remote/service/media_service.dart';
import '../core/data/datasources/remote/service/order_service.dart';
import '../core/data/datasources/remote/service/shipping_service.dart';
import '../core/data/datasources/remote/service/store_service.dart';
import '../core/data/datasources/remote/service/verification_service.dart';
import '../core/data/local/session_store.dart';
import '../core/data/repositories/auth_repository_impl.dart';
import '../core/data/repositories/catalog_repository_impl.dart';
import '../core/data/repositories/inventory_repository_impl.dart';
import '../core/data/repositories/order_repository_impl.dart';
import '../core/data/repositories/shipping_repository_impl.dart';
import '../core/data/repositories/store_repository_impl.dart';
import '../core/data/repositories/verification_repository_impl.dart';
import '../core/domain/repositories/auth_repository.dart';
import '../core/domain/repositories/catalog_repository.dart';
import '../core/domain/repositories/inventory_repository.dart';
import '../core/domain/repositories/order_repository.dart';
import '../core/domain/repositories/shipping_repository.dart';
import '../core/domain/repositories/store_repository.dart';
import '../core/domain/repositories/verification_repository.dart';
import 'injector.dart';

/// Repositories take services, so this runs after [initializeService].
void initializeRepository() {
  injector.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      injector<AuthService>(),
      injector<SessionStore>(),
    ),
  );

  injector.registerLazySingleton<StoreRepository>(
    () => StoreRepositoryImpl(
      injector<StoreService>(),
      injector<MediaService>(),
    ),
  );

  injector.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(injector<CatalogService>()),
  );

  injector.registerLazySingleton<VerificationRepository>(
    () => VerificationRepositoryImpl(injector<VerificationService>()),
  );

  injector.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(injector<InventoryService>()),
  );

  injector.registerLazySingleton<ShippingRepository>(
    () => ShippingRepositoryImpl(injector<ShippingService>()),
  );

  injector.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(injector<OrderService>()),
  );
}
