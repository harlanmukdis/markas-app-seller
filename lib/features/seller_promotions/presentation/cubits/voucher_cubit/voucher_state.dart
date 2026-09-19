part of 'voucher_cubit.dart';

sealed class VoucherState {
  const VoucherState();
}

final class VoucherInProgress extends VoucherState {
  const VoucherInProgress();
}

final class VoucherNoStore extends VoucherState {
  const VoucherNoStore();
}

final class VoucherFailure extends VoucherState {
  const VoucherFailure(this.error);

  final DataError error;
}

final class VoucherLoaded extends VoucherState {
  const VoucherLoaded(this.vouchers, {this.isBusy = false});

  final List<StoreVoucher> vouchers;
  final bool isBusy;

  /// Worked out once per build rather than per row, so every pill on the screen
  /// is judged against the same instant.
  List<({StoreVoucher voucher, VoucherPhase phase})> phased(DateTime now) =>
      vouchers
          .map((voucher) => (voucher: voucher, phase: voucher.phaseAt(now)))
          .toList(growable: false);

  VoucherLoaded copyWith({List<StoreVoucher>? vouchers, bool? isBusy}) =>
      VoucherLoaded(vouchers ?? this.vouchers, isBusy: isBusy ?? this.isBusy);
}
