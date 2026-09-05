import '../../data_state.dart';
import '../model/auth/auth_session.dart';
import '../model/auth/user_model.dart';

abstract class AuthRepository {
  /// Registers a store and persists the returned session.
  ///
  /// Because `register` returns no refresh token, the implementation follows up
  /// with a login so the app does not end up with a 2-hour session that cannot
  /// be renewed (API doc 1.4).
  Future<DataState<AuthSession>> register({
    required String phone,
    required String password,
    required String fullName,
    required String tokoName,
    String sellerType,
    String? email,
  });

  Future<DataState<AuthSession>> login({
    required String phone,
    required String password,
  });

  Future<DataState<UserModel>> me();

  Future<void> logout();

  bool get isLoggedIn;

  int? get sellerId;
}
