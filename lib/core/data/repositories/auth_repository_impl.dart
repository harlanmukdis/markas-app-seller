import '../../../config/network/api_exception.dart';
import '../../data_state.dart';
import '../../domain/model/auth/auth_session.dart';
import '../../domain/model/auth/user_model.dart';
import '../../domain/model/enums.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/service/auth_service.dart';
import '../local/session_store.dart';
import 'repository_guard.dart';

class AuthRepositoryImpl with RepositoryGuard implements AuthRepository {
  const AuthRepositoryImpl(this._authService, this._sessionStore);

  final AuthService _authService;
  final SessionStore _sessionStore;

  @override
  bool get isLoggedIn => _sessionStore.isLoggedIn;

  @override
  int? get sellerId => _sessionStore.sellerId;

  @override
  Future<DataState<AuthSession>> register({
    required String phone,
    required String password,
    required String fullName,
    required String tokoName,
    String sellerType = SellerType.toko,
    String? email,
  }) =>
      guard(() async {
        final registered = await _authService.register(
          phone: phone,
          password: password,
          fullName: fullName,
          tokoName: tokoName,
          sellerType: sellerType,
          email: email,
        );
        await _sessionStore.save(registered);
        await _sessionStore.saveProfile(fullName: fullName, phone: phone);

        // `register` hands back only a 2-hour access token. Logging straight in
        // is the documented way to obtain a refresh token (API doc 1.4);
        // without it the store is silently signed out two hours later with no
        // way to renew.
        try {
          final session = await _authService.login(
            phone: phone,
            password: password,
          );
          await _sessionStore.save(session);
          return session;
        } on ApiException {
          // Registration itself succeeded — do not fail the flow over this.
          // The session just cannot outlive its access token.
          return registered;
        }
      });

  @override
  Future<DataState<AuthSession>> login({
    required String phone,
    required String password,
  }) =>
      guard(() async {
        final session = await _authService.login(
          phone: phone,
          password: password,
        );
        await _sessionStore.save(session);
        await _sessionStore.saveProfile(phone: phone);
        return session;
      });

  @override
  Future<DataState<UserModel>> me() => guard(() async {
        final user = await _authService.me();
        await _sessionStore.saveProfile(
          fullName: user.fullName,
          phone: user.phone,
        );
        return user;
      });

  @override
  Future<void> logout() => _sessionStore.clear();
}
