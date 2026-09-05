import '../../data_state.dart';
import '../model/order/order_model.dart';

abstract class OrderRepository {
  Future<DataState<List<OrderModel>>> getOrders();

  Future<DataState<OrderModel>> getOrder(int orderId);

  /// The store's own sub-orders, flattened out of the order list — this is
  /// what the "Pesanan Masuk" screen shows.
  Future<DataState<List<SubOrder>>> getSubOrders();

  Future<DataState<SubOrder>> getSubOrder(int subOrderId);

  /// Resolves a flat `GET /orders` row to the sub-order it really refers to.
  /// Call this before any action — the list row's id is not reliable.
  Future<DataState<SubOrder>> resolveSubOrder(SubOrder listRow);

  Future<DataState<String>> confirm(int subOrderId);

  /// [reason] must be one of [RejectReason.all].
  Future<DataState<String>> reject(int subOrderId, {required String reason});

  Future<DataState<String>> readyToShip(int subOrderId);
}
