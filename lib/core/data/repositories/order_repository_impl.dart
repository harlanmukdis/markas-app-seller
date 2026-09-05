import '../../data_state.dart';
import '../../domain/model/order/order_model.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/remote/service/order_service.dart';
import 'repository_guard.dart';

class OrderRepositoryImpl with RepositoryGuard implements OrderRepository {
  const OrderRepositoryImpl(this._service);

  final OrderService _service;

  @override
  Future<DataState<List<OrderModel>>> getOrders() =>
      guard(() => _service.getOrders());

  @override
  Future<DataState<OrderModel>> getOrder(int orderId) =>
      guard(() => _service.getOrder(orderId));

  @override
  Future<DataState<List<SubOrder>>> getSubOrders() =>
      guard(() => _service.getSubOrders());

  @override
  Future<DataState<SubOrder>> getSubOrder(int subOrderId) =>
      guard(() => _service.getSubOrder(subOrderId));

  @override
  Future<DataState<SubOrder>> resolveSubOrder(SubOrder listRow) =>
      guard(() => _service.resolveSubOrder(listRow));

  @override
  Future<DataState<String>> confirm(int subOrderId) =>
      guard(() => _service.confirm(subOrderId));

  @override
  Future<DataState<String>> reject(int subOrderId, {required String reason}) =>
      guard(() => _service.reject(subOrderId, reason: reason));

  @override
  Future<DataState<String>> readyToShip(int subOrderId) =>
      guard(() => _service.readyToShip(subOrderId));
}
