import '../../data_state.dart';
import '../../domain/model/auth/auth_session.dart';
import '../../domain/model/user/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/service/auth_service.dart';
import '../local/session_store.dart';
import 'repository_guard.dart';

class AuthRepositoryImpl with RepositoryGuard implements AuthRepository {
  const AuthRepositoryImpl(this._service, this._session);

  final AuthService _service;
  final SessionStore _session;

  @override
  Future<DataState<RegistrationResult>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) =>
      guard(() => _service.register(
            email: email,
            password: password,
            fullName: fullName,
            phone: phone,
          ));

  @override
  Future<DataState<bool>> verifyEmail(String token) => guard(() async {
        await _service.verifyEmail(token);
        return true;
      });

  @override
  Future<DataState<bool>> resendVerification(String email) => guard(() async {
        await _service.resendVerification(email);
        return true;
      });

  @override
  Future<DataState<AuthSession>> login({
    required String email,
    required String password,
  }) =>
      guard(() async {
        final session = await _service.login(email: email, password: password);
        await _session.save(session);

        // The tokens carry no identity, so the profile is fetched immediately
        // and cached — otherwise every screen would have to ask who it is.
        try {
          final user = await _service.me();
          await _session.saveProfile(
            userId: user.id,
            fullName: user.fullName,
            email: user.email,
            phone: user.phone,
          );
          // Owning exactly one store makes the choice for the user; owning
          // several is a question the shell has to ask.
          if (user.stores.length == 1) {
            await _session.saveActiveStore(user.stores.single.id);
          }
        } catch (_) {
          // A failed profile read must not undo a successful login.
        }

        return session;
      });

  @override
  Future<DataState<AppUser>> me() => guard(() async {
        final user = await _service.me();
        await _session.saveProfile(
          userId: user.id,
          fullName: user.fullName,
          email: user.email,
          phone: user.phone,
        );
        return user;
      });

  @override
  Future<DataState<bool>> forgotPassword(String email) => guard(() async {
        await _service.forgotPassword(email);
        return true;
      });

  @override
  Future<DataState<bool>> resetPassword({
    required String token,
    required String newPassword,
  }) =>
      guard(() async {
        await _service.resetPassword(token: token, newPassword: newPassword);
        return true;
      });

  @override
  Future<void> logout() async {
    final refresh = _session.refreshToken;
    if (refresh != null && refresh.isNotEmpty) {
      // Best effort: a server that refuses the revoke must not trap the user
      // in a session they have asked to leave.
      try {
        await _service.logout(refresh);
      } catch (_) {}
    }
    await _session.clear();
  }

  @override
  bool get isLoggedIn => _session.isLoggedIn;

  @override
  int? get activeStoreId => _session.activeStoreId;

  @override
  Future<void> setActiveStore(int storeId) => _session.saveActiveStore(storeId);
}
