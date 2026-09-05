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

  /// `Jawa Barat › Bekasi › Bekasi Kota`.
  ///
  /// Leaf zone names on their own are ambiguous in a flat list — several
  /// cities have a "Kota"/"Kabupaten" pair — so the parent chain is walked to
  /// make the picker readable.
  String zonePathLabel(Zone zone) {
    final byId = <int, Zone>{for (final z in zones) z.id: z};
    final segments = <String>[zone.name];

    var parentId = zone.parentId;
    // Bounded rather than `while (parentId != null)`: a cycle in the data
    // would otherwise hang the build.
    for (var depth = 0; depth < 4 && parentId != null; depth++) {
      final parent = byId[parentId];
      if (parent == null) break;
      segments.insert(0, parent.name);
      parentId = parent.parentId;
    }

    return segments.join(' › ');
  }

  String zoneNameFor(int zoneId) {
    for (final zone in zones) {
      if (zone.id == zoneId) return zonePathLabel(zone);
    }
    return 'Zona $zoneId';
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
