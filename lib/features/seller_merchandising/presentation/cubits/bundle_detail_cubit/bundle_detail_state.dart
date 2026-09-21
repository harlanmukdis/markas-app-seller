part of 'bundle_detail_cubit.dart';

sealed class BundleDetailState {
  const BundleDetailState();
}

final class BundleDetailInProgress extends BundleDetailState {
  const BundleDetailInProgress();
}

final class BundleDetailNoStore extends BundleDetailState {
  const BundleDetailNoStore();
}

final class BundleDetailFailure extends BundleDetailState {
  const BundleDetailFailure(this.error);

  final DataError error;
}

final class BundleDetailLoaded extends BundleDetailState {
  const BundleDetailLoaded({
    required this.bundle,
    this.itemsAreHidden = false,
    this.isBusy = false,
  });

  final ProductBundle bundle;

  /// The bundle is switched off, so the endpoint that carries its items
  /// refuses it. Not an error — the row is fine and the contents still exist
  /// in the database; they are simply unreadable until it is switched back on.
  final bool itemsAreHidden;

  final bool isBusy;

  BundleDetailLoaded copyWith({
    ProductBundle? bundle,
    bool? itemsAreHidden,
    bool? isBusy,
  }) =>
      BundleDetailLoaded(
        bundle: bundle ?? this.bundle,
        itemsAreHidden: itemsAreHidden ?? this.itemsAreHidden,
        isBusy: isBusy ?? this.isBusy,
      );
}
