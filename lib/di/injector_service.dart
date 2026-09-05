import '../core/data/datasources/remote/service/auth_service.dart';
import '../core/data/datasources/remote/service/seller_service.dart';
import '../core/data/datasources/remote/service/shipping_rate_service.dart';
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
}
