import '../../data_state.dart';
import '../../domain/model/shipping/fleet_type.dart';
import '../../domain/model/shipping/shipping_rate.dart';
import '../../domain/model/shipping/zone.dart';
import '../../domain/repositories/shipping_rate_repository.dart';
import '../datasources/remote/service/shipping_rate_service.dart';
import 'repository_guard.dart';

class ShippingRateRepositoryImpl
    with RepositoryGuard
    implements ShippingRateRepository {
  const ShippingRateRepositoryImpl(this._shippingRateService);

  final ShippingRateService _shippingRateService;

  @override
  Future<DataState<List<ShippingRate>>> getRates() =>
      guard(() => _shippingRateService.getRates());

  @override
  Future<DataState<ShippingRate>> createRate({
    required int zoneId,
    required String fleetTypeCode,
    required int baseRate,
    String? mode,
    int? kuliBongkarFee,
    int? lantaiAtasFee,
    int? aksesSulitFee,
  }) =>
      guard(() => _shippingRateService.createRate(
            zoneId: zoneId,
            fleetTypeCode: fleetTypeCode,
            baseRate: baseRate,
            mode: mode,
            kuliBongkarFee: kuliBongkarFee,
            lantaiAtasFee: lantaiAtasFee,
            aksesSulitFee: aksesSulitFee,
          ));

  @override
  Future<DataState<bool>> deleteRate(int rateId) => guard(() async {
        await _shippingRateService.deleteRate(rateId);
        return true;
      });

  @override
  Future<DataState<List<Zone>>> getZones({bool forceRefresh = false}) =>
      guard(() => _shippingRateService.getZones(forceRefresh: forceRefresh));

  @override
  Future<DataState<List<FleetType>>> getFleetTypes({
    bool forceRefresh = false,
  }) =>
      guard(
        () => _shippingRateService.getFleetTypes(forceRefresh: forceRefresh),
      );
}
