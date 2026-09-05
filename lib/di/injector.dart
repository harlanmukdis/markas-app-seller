import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../config/network/dio_client.dart';
import '../core/data/local/session_store.dart';
import 'injector_repository.dart';
import 'injector_service.dart';

final GetIt injector = GetIt.instance;

/// Wires the object graph. Must run before `runApp`.
///
/// Registration order is the dependency order and is not incidental:
/// session store -> named Dio -> services -> repositories. A service resolved
/// before the Dio it needs would throw at startup.
Future<void> initialize({void Function()? onSessionExpired}) async {
  injector.registerLazySingleton<SessionStore>(SessionStore.new);

  // One named Dio singleton. A feature domain that later talks to a different
  // base URL registers its own named instance here rather than reconfiguring
  // this one mid-flight.
  injector.registerSingleton<Dio>(
    DioClient.create(
      sessionStore: injector<SessionStore>(),
      onSessionExpired: onSessionExpired,
    ),
    instanceName: DioClient.apiInstanceName,
  );

  initializeService();
  initializeRepository();
}

/// Convenience accessor for the `"api"` Dio instance.
Dio get apiDio => injector<Dio>(instanceName: DioClient.apiInstanceName);
