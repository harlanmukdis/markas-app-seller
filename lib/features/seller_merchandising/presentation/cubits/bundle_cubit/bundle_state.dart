part of 'bundle_cubit.dart';

sealed class BundleState {
  const BundleState();
}

final class BundleInProgress extends BundleState {
  const BundleInProgress();
}

final class BundleNoStore extends BundleState {
  const BundleNoStore();
}

final class BundleFailure extends BundleState {
  const BundleFailure(this.error);

  final DataError error;
}

final class BundleLoaded extends BundleState {
  const BundleLoaded(this.bundles, {this.isBusy = false});

  /// Newest first. **Without items** — the listing does not join them, so
  /// every row here has an empty `items` and a screen wanting contents has to
  /// open the bundle.
  final List<ProductBundle> bundles;

  final bool isBusy;

  /// The ones a buyer can actually see. An inactive bundle is also the one
  /// whose contents the API refuses to return, so the two facts travel
  /// together.
  List<ProductBundle> get active =>
      bundles.where((bundle) => bundle.isActive).toList(growable: false);

  BundleLoaded copyWith({List<ProductBundle>? bundles, bool? isBusy}) =>
      BundleLoaded(bundles ?? this.bundles, isBusy: isBusy ?? this.isBusy);
}
