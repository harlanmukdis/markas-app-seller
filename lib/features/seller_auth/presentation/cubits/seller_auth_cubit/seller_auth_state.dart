part of 'seller_auth_cubit.dart';

sealed class SellerAuthState {
  const SellerAuthState();
}

final class SellerAuthIdle extends SellerAuthState {
  const SellerAuthIdle();
}

final class SellerAuthInProgress extends SellerAuthState {
  const SellerAuthInProgress();
}

/// Emitted after a successful login or registration. The view navigates on
/// this; the session itself is already persisted by the repository.
final class SellerAuthSuccess extends SellerAuthState {
  const SellerAuthSuccess(this.session);

  final AuthSession session;
}
