import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/merchandising/product_bundle.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/merchandising_repository.dart';
import '../../../../../di/injector.dart';

part 'bundle_detail_state.dart';

/// One bundle and what is in it.
///
/// The awkward part is that `GET /bundles/{id}` serves **active bundles
/// only**, so an inactive bundle's contents are unreachable — to its owner as
/// much as to anyone. Rather than showing that as a 404, this reads the row
/// from the store's list first (which does include inactive bundles) and only
/// then asks for the items, so a switched-off bundle can still show its name,
/// price and status, and say plainly why the contents are missing.
class BundleDetailCubit extends Cubit<BundleDetailState> {
  BundleDetailCubit(this.bundleId) : super(const BundleDetailInProgress());

  static BundleDetailCubit get(BuildContext context) =>
      BlocProvider.of(context);

  final int bundleId;

  final MerchandisingRepository _merchandising =
      injector<MerchandisingRepository>();
  final AuthRepository _auth = injector<AuthRepository>();

  Future<void> load() async {
    if (isClosed) return;

    final storeId = _auth.activeStoreId;
    if (storeId == null) {
      emit(const BundleDetailNoStore());
      return;
    }

    emit(const BundleDetailInProgress());

    final list = await _merchandising.getStoreBundles(storeId);
    if (isClosed) return;

    if (list is DataFailed<List<ProductBundle>>) {
      emit(BundleDetailFailure(list.failure));
      return;
    }

    final summary = switch (list) {
      DataSuccess<List<ProductBundle>>(:final value) =>
        value.where((bundle) => bundle.id == bundleId).firstOrNull,
      _ => null,
    };

    if (summary == null) {
      emit(const BundleDetailFailure(
        DataError(
          code: 'BUNDLE_NOT_FOUND',
          message: 'Bundel ini tidak ada di toko yang sedang aktif.',
        ),
      ));
      return;
    }

    // Only an active bundle has readable contents. Asking anyway would
    // answer 404 with the bare error code as its message.
    if (!summary.isActive) {
      emit(BundleDetailLoaded(bundle: summary, itemsAreHidden: true));
      return;
    }

    final detail = await _merchandising.getBundle(bundleId);
    if (isClosed) return;

    switch (detail) {
      case DataSuccess<ProductBundle>(:final value):
        emit(BundleDetailLoaded(bundle: value));
      case DataFailed<ProductBundle>():
        // The row exists but the detail refused it — treat it as the same
        // hidden-contents case rather than losing the screen entirely.
        emit(BundleDetailLoaded(bundle: summary, itemsAreHidden: true));
      default:
        emit(BundleDetailLoaded(bundle: summary, itemsAreHidden: true));
    }
  }

  /// Switching a bundle off also hides its contents, so the screen reloads
  /// into the hidden state rather than keeping stale items on display.
  Future<DataError?> setActive(bool isActive) async {
    final storeId = _auth.activeStoreId;
    final current = state;
    if (storeId == null || current is! BundleDetailLoaded) return null;

    emit(current.copyWith(isBusy: true));
    final result = await _merchandising.updateBundle(
      storeId,
      bundleId,
      status: isActive ? BundleStatus.active : BundleStatus.inactive,
    );
    if (isClosed) return null;

    if (result is DataFailed<List<ProductBundle>>) {
      emit(current.copyWith(isBusy: false));
      return result.failure;
    }

    await load();
    return null;
  }
}
