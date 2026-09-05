part of 'onboarding_cubit.dart';

sealed class OnboardingState {
  const OnboardingState();
}

final class OnboardingLoadInProgress extends OnboardingState {
  const OnboardingLoadInProgress();
}

final class OnboardingLoadSuccess extends OnboardingState {
  const OnboardingLoadSuccess({
    required this.seller,
    required this.warehouses,
    this.warehouseError,
    this.isBusy = false,
  });

  final SellerModel seller;
  final List<Warehouse> warehouses;

  /// Kept separate from the page-level failure: the warehouse list is a
  /// secondary read, and losing it should not blank out the gate checklist.
  final DataError? warehouseError;

  final bool isBusy;

  ActivationGates get gates => seller.activationGates;

  /// Not one of the four gates, but a buyer's checkout fails with
  /// `409 NO_WAREHOUSE` without it — even for a `VERIFIED` store (API doc 5.2).
  bool get needsWarehouse => warehouseError == null && warehouses.isEmpty;

  bool get isReadyToSell => gates.allPassed && warehouses.isNotEmpty;

  OnboardingLoadSuccess copyWith({
    SellerModel? seller,
    List<Warehouse>? warehouses,
    DataError? warehouseError,
    bool? isBusy,
  }) =>
      OnboardingLoadSuccess(
        seller: seller ?? this.seller,
        warehouses: warehouses ?? this.warehouses,
        warehouseError: warehouseError ?? this.warehouseError,
        isBusy: isBusy ?? this.isBusy,
      );
}

final class OnboardingLoadFailure extends OnboardingState {
  const OnboardingLoadFailure(this.error);

  final DataError error;
}
