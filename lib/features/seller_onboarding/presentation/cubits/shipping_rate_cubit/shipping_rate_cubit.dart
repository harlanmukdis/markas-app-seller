import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/shipping/fleet_type.dart';
import '../../../../../core/domain/model/shipping/shipping_rate.dart';
import '../../../../../core/domain/model/shipping/zone.dart';
import '../../../../../core/domain/repositories/shipping_rate_repository.dart';
import '../../../../../di/injector.dart';

part 'shipping_rate_state.dart';

/// Gate 3. The platform fixes the shape of the tariff form; the store fills in
/// the numbers.
class ShippingRateCubit extends Cubit<ShippingRateState> {
  ShippingRateCubit() : super(const ShippingRateLoadInProgress());

  static ShippingRateCubit get(BuildContext context) =>
      BlocProvider.of(context);

  final ShippingRateRepository _shippingRateRepository =
      injector<ShippingRateRepository>();

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) emit(const ShippingRateLoadInProgress());

    final results = await Future.wait(<Future<Object>>[
      _shippingRateRepository.getRates(),
      _shippingRateRepository.getZones(),
      _shippingRateRepository.getFleetTypes(),
    ]);

    if (isClosed) return;

    final rateResult = results[0] as DataState<List<ShippingRate>>;
    final zoneResult = results[1] as DataState<List<Zone>>;
    final fleetResult = results[2] as DataState<List<FleetType>>;

    if (rateResult is DataFailed<List<ShippingRate>>) {
      emit(ShippingRateLoadFailure(rateResult.failure));
      return;
    }

    emit(
      ShippingRateLoadSuccess(
        rates: _itemsOf(rateResult),
        zones: _itemsOf(zoneResult),
        fleetTypes: _itemsOf(fleetResult),
        referenceDataError: _firstFailure(<DataState<Object>>[
          zoneResult,
          fleetResult,
        ]),
      ),
    );
  }

  /// Upserts on (zone, fleet type). Adding the first rate re-checks the
  /// activation gates, so a store whose other three gates already passed comes
  /// back `VERIFIED` from this same call.
  Future<DataError?> create({
    required int zoneId,
    required String fleetTypeCode,
    required int baseRate,
    String? mode,
    int? kuliBongkarFee,
    int? lantaiAtasFee,
    int? aksesSulitFee,
  }) async {
    final current = state;
    if (current is ShippingRateLoadSuccess) emit(current.copyWith(isBusy: true));

    final result = await _shippingRateRepository.createRate(
      zoneId: zoneId,
      fleetTypeCode: fleetTypeCode,
      baseRate: baseRate,
      mode: mode,
      kuliBongkarFee: kuliBongkarFee,
      lantaiAtasFee: lantaiAtasFee,
      aksesSulitFee: aksesSulitFee,
    );

    if (isClosed) return null;

    switch (result) {
      case DataSuccess<ShippingRate>():
        await load(showSpinner: false);
        return null;
      case DataFailed<ShippingRate>(:final failure):
        if (current is ShippingRateLoadSuccess) {
          emit(current.copyWith(isBusy: false));
        }
        return failure;
      case DataLoading<ShippingRate>():
      case DataEmpty<ShippingRate>():
        if (current is ShippingRateLoadSuccess) {
          emit(current.copyWith(isBusy: false));
        }
        return const DataError(
          code: DataErrorCode.unexpected,
          message: 'Server tidak mengembalikan data tarif.',
        );
    }
  }

  Future<DataError?> delete(int rateId) async {
    final current = state;
    if (current is ShippingRateLoadSuccess) emit(current.copyWith(isBusy: true));

    final result = await _shippingRateRepository.deleteRate(rateId);
    if (isClosed) return null;

    if (result is DataFailed<bool>) {
      if (current is ShippingRateLoadSuccess) {
        emit(current.copyWith(isBusy: false));
      }
      return result.failure;
    }

    await load(showSpinner: false);
    return null;
  }

  static List<T> _itemsOf<T>(DataState<List<T>> state) => switch (state) {
        DataSuccess<List<T>>(:final value) => value,
        _ => const <Never>[],
      };

  static DataError? _firstFailure(List<DataState<Object>> states) {
    for (final state in states) {
      if (state is DataFailed<Object>) return state.failure;
    }
    return null;
  }
}
