import '../../data_state.dart';
import '../../domain/model/shipping/courier.dart';
import '../../domain/repositories/shipping_repository.dart';
import '../datasources/remote/service/shipping_service.dart';
import 'repository_guard.dart';

class ShippingRepositoryImpl with RepositoryGuard implements ShippingRepository {
  const ShippingRepositoryImpl(this._service);

  final ShippingService _service;

  @override
  Future<DataState<List<Courier>>> getCouriers() =>
      guard(() => _service.getCouriers());

  @override
  Future<DataState<List<Courier>>> getStoreCouriers(int storeId) =>
      guard(() => _service.getStoreCouriers(storeId));

  @override
  Future<DataState<List<Courier>>> setStoreCouriers(
    int storeId,
    List<String> courierCodes,
  ) =>
      guard(() => _service.setStoreCouriers(storeId, courierCodes));
}
