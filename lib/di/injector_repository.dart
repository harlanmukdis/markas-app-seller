import '../core/data/datasources/remote/service/auth_service.dart';
import '../core/data/datasources/remote/service/media_service.dart';
import '../core/data/datasources/remote/service/store_service.dart';
import '../core/data/local/session_store.dart';
import '../core/data/repositories/auth_repository_impl.dart';
import '../core/data/repositories/store_repository_impl.dart';
import '../core/domain/repositories/auth_repository.dart';
import '../core/domain/repositories/store_repository.dart';
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
}
