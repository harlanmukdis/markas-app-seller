import '../../data_state.dart';
import '../model/shipping/fleet_type.dart';
import '../model/shipping/shipping_rate.dart';
import '../model/shipping/zone.dart';

abstract class ShippingRateRepository {
  Future<DataState<List<ShippingRate>>> getRates();

  Future<DataState<ShippingRate>> createRate({
    required int zoneId,
    required String fleetTypeCode,
    required int baseRate,
    String? mode,
    int? kuliBongkarFee,
    int? lantaiAtasFee,
    int? aksesSulitFee,
  });

  /// Resolves to `true` on success. A `void` payload would make `DataState`
  /// awkward to construct, and callers want a plain yes/no here anyway.
  Future<DataState<bool>> deleteRate(int rateId);

  Future<DataState<List<Zone>>> getZones({bool forceRefresh});

  Future<DataState<List<FleetType>>> getFleetTypes({bool forceRefresh});
}
