part of 'dashboard_cubit.dart';

sealed class DashboardState {
  const DashboardState();
}

final class DashboardLoadInProgress extends DashboardState {
  const DashboardLoadInProgress();
}

final class DashboardLoadSuccess extends DashboardState {
  const DashboardLoadSuccess({
    required this.seller,
    this.balance,
    this.performance,
    this.pendingSubOrders = 0,
    this.responseRate,
  });

  final SellerModel seller;

  /// Secondary reads. Any of these may be null because the endpoint failed —
  /// losing the balance should not blank out the whole dashboard.
  final SellerBalance? balance;
  final SellerPerformance? performance;
  final ChatResponseRate? responseRate;

  /// Sub-orders still waiting on this store — the number that actually costs
  /// money if ignored.
  final int pendingSubOrders;

  bool get isVerified => seller.status == SellerStatus.verified;

  bool get needsActivation => !seller.activationGates.allPassed;
}

final class DashboardLoadFailure extends DashboardState {
  const DashboardLoadFailure(this.error);

  final DataError error;
}
