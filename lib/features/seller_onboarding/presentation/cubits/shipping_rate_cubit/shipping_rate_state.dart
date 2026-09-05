part of 'shipping_rate_cubit.dart';

sealed class ShippingRateState {
  const ShippingRateState();
}

final class ShippingRateLoadInProgress extends ShippingRateState {
  const ShippingRateLoadInProgress();
}

final class ShippingRateLoadSuccess extends ShippingRateState {
  const ShippingRateLoadSuccess({
    required this.rates,
    required this.zones,
    required this.fleetTypes,
    this.referenceDataError,
    this.isBusy = false,
  });

  final List<ShippingRate> rates;

  /// Platform reference data for the create form. If it could not be fetched,
  /// [referenceDataError] is set and the form falls back to manual entry
  /// rather than blocking the whole screen.
  final List<Zone> zones;
  final List<FleetType> fleetTypes;
  final DataError? referenceDataError;

  final bool isBusy;

  /// Only leaf zones can carry a tariff row; provinces and cities are grouping
  /// levels (API doc 5.3).
  List<Zone> get selectableZones {
    final leaves = zones.where((zone) => zone.isLeafZone).toList();
    return leaves.isEmpty ? zones : leaves;
  }

  ShippingRateLoadSuccess copyWith({
    List<ShippingRate>? rates,
    List<Zone>? zones,
    List<FleetType>? fleetTypes,
    DataError? referenceDataError,
    bool? isBusy,
  }) =>
      ShippingRateLoadSuccess(
        rates: rates ?? this.rates,
        zones: zones ?? this.zones,
        fleetTypes: fleetTypes ?? this.fleetTypes,
        referenceDataError: referenceDataError ?? this.referenceDataError,
        isBusy: isBusy ?? this.isBusy,
      );
}

final class ShippingRateLoadFailure extends ShippingRateState {
  const ShippingRateLoadFailure(this.error);

  final DataError error;
}
