import '../core/data/datasources/remote/service/auth_service.dart';
import '../core/data/datasources/remote/service/seller_service.dart';
import '../core/data/datasources/remote/service/shipping_rate_service.dart';
import '../core/data/local/session_store.dart';
import '../core/data/repositories/auth_repository_impl.dart';
import '../core/data/repositories/seller_repository_impl.dart';
import '../core/data/repositories/shipping_rate_repository_impl.dart';
import '../core/domain/repositories/auth_repository.dart';
import '../core/domain/repositories/seller_repository.dart';
import '../core/domain/repositories/shipping_rate_repository.dart';
import 'injector.dart';

/// Repositories are registered against their **abstract** type, which is what
/// cubits ask for: `injector<SellerRepository>()`.
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
}
