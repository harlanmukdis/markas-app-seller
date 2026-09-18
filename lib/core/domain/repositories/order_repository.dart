import '../../data_state.dart';
import '../model/order/order.dart';

/// The store's orders and the actions that move them along.
///
/// Every action returns the order as it stands afterwards, because none of the
/// endpoints answer with one. Callers must still check the `can*` flags on
/// [Order] first: an out-of-order transition fails in a way the API cannot
/// report properly.
abstract class OrderRepository {
  Future<DataState<List<Order>>> getStoreOrders(
    int storeId, {
    String? status,
    int page,
  });

  Future<DataState<Order>> getOrder(int orderId);

  Future<DataState<Order>> accept(int orderId);

  Future<DataState<Order>> pack(int orderId);

  Future<DataState<Order>> ship(
    int orderId, {
    required String courierCode,
    required String awbNumber,
  });

  Future<DataState<Order>> cancel(int orderId, {required String reason});

  /// [DataEmpty] until the order ships.
  Future<DataState<OrderShipment>> getTracking(int orderId);

  Future<DataState<Order>> approveRefund(int orderId, int refundId);

  Future<DataState<Order>> rejectRefund(int orderId, int refundId);
}
