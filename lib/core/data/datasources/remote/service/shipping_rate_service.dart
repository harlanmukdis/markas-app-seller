import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/shipping/fleet_type.dart';
import '../../../../domain/model/shipping/shipping_rate.dart';
import '../../../../domain/model/shipping/zone.dart';
import 'base_service.dart';

class ShippingRateService extends BaseService {
  ShippingRateService(super.dio);

  /// Zones and fleet types are platform reference data that never changes
  /// during a session, so they are cached in memory after the first read
  /// rather than re-fetched every time a tariff form opens.
  List<Zone>? _zonesCache;
  List<FleetType>? _fleetTypesCache;

  /// With a `SEL` token this already returns only this store's rates — no
  /// seller filter is needed, or possible (API doc 2).
  Future<List<ShippingRate>> getRates() async {
    final envelope = await getRequest(ApiEndpoints.shippingRates);
    return envelope
        .listAt('shipping_rates')
        .map(ShippingRate.fromJson)
        .toList(growable: false);
  }

  /// Upserts on the unique key (seller, zone, fleet type): 201 when new, 200
  /// when it replaces an existing row. Safe to call repeatedly.
  ///
  /// Adding the first rate re-checks the activation gates, so a store whose
  /// other three gates already passed becomes `VERIFIED` in this same response.
  Future<ShippingRate> createRate({
    required int zoneId,
    required String fleetTypeCode,
    required int baseRate,
    String? mode,
    int? kuliBongkarFee,
    int? lantaiAtasFee,
    int? aksesSulitFee,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.shippingRates,
      body: <String, dynamic>{
        'zone_id': zoneId,
        'fleet_type_code': fleetTypeCode,
        'base_rate': baseRate,
        'mode': mode,
        'kuli_bongkar_fee': kuliBongkarFee,
        'lantai_atas_fee': lantaiAtasFee,
        'akses_sulit_fee': aksesSulitFee,
      },
    );
    return ShippingRate.fromJson(envelope.map);
  }

  Future<void> deleteRate(int rateId) async {
    await deleteRequest(ApiEndpoints.shippingRate(rateId));
  }

  Future<List<Zone>> getZones({bool forceRefresh = false}) async {
    final cached = _zonesCache;
    if (cached != null && !forceRefresh) return cached;

    final envelope = await getRequest(ApiEndpoints.zones);
    final zones =
        envelope.listAt('zones').map(Zone.fromJson).toList(growable: false);
    _zonesCache = zones;
    return zones;
  }

  Future<List<FleetType>> getFleetTypes({bool forceRefresh = false}) async {
    final cached = _fleetTypesCache;
    if (cached != null && !forceRefresh) return cached;

    final envelope = await getRequest(ApiEndpoints.fleetTypes);
    final fleetTypes = envelope
        .listAt('fleet_types')
        .map(FleetType.fromJson)
        .toList(growable: false);
    _fleetTypesCache = fleetTypes;
    return fleetTypes;
  }
}
