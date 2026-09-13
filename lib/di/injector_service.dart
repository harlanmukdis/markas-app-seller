import 'package:dio/dio.dart';

import '../core/data/datasources/remote/service/auth_service.dart';
import '../core/data/datasources/remote/service/media_service.dart';
import '../core/data/datasources/remote/service/store_service.dart';
import '../config/network/dio_client.dart';
import 'injector.dart';

/// Services take the named `"api"` Dio instance and are registered before the
/// repositories that depend on them.
void initializeService() {
  final dio = injector<Dio>(instanceName: DioClient.apiInstanceName);

  injector.registerLazySingleton<AuthService>(() => AuthService(dio));
  injector.registerLazySingleton<StoreService>(() => StoreService(dio));
  injector.registerLazySingleton<MediaService>(() => MediaService(dio));
}
