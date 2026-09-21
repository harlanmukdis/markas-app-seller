part of 'showcase_cubit.dart';

sealed class ShowcaseState {
  const ShowcaseState();
}

final class ShowcaseInProgress extends ShowcaseState {
  const ShowcaseInProgress();
}

final class ShowcaseNoStore extends ShowcaseState {
  const ShowcaseNoStore();
}

final class ShowcaseFailure extends ShowcaseState {
  const ShowcaseFailure(this.error);

  final DataError error;
}

final class ShowcaseLoaded extends ShowcaseState {
  const ShowcaseLoaded(this.showcases, {this.isBusy = false});

  /// Ordered by `sort_order`, as the server returns them. The list carries no
  /// product count, so a showcase's size is unknown until it is opened.
  final List<StoreShowcase> showcases;

  final bool isBusy;

  /// The next free position, so a new showcase lands at the end rather than
  /// colliding with an existing one — the server allows duplicates and does
  /// not renumber.
  int get nextSortOrder => showcases.isEmpty
      ? 0
      : showcases.map((s) => s.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

  ShowcaseLoaded copyWith({List<StoreShowcase>? showcases, bool? isBusy}) =>
      ShowcaseLoaded(showcases ?? this.showcases,
          isBusy: isBusy ?? this.isBusy);
}
