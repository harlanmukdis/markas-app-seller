import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/order/order_model.dart';
import 'base_service.dart';

class OrderService extends BaseService {
  const OrderService(super.dio);

  /// With a `SEL` token, only orders containing this store's sub-orders.
  /// Capped at the 50 most recent, with no pagination (API doc 8).
  Future<List<OrderModel>> getOrders() async {
    final envelope = await getRequest(ApiEndpoints.orders);
    return envelope
        .listAt('orders')
        .map(OrderModel.fromJson)
        .toList(growable: false);
  }

  Future<OrderModel> getOrder(int orderId) async {
    final envelope = await getRequest(ApiEndpoints.order(orderId));
    return OrderModel.fromJson(envelope.map);
  }

  Future<SubOrder> getSubOrder(int subOrderId) async {
    final envelope = await getRequest(ApiEndpoints.subOrder(subOrderId));
    return SubOrder.fromJson(envelope.map);
  }

  /// Flattens this store's sub-orders out of the order list, since the
  /// "Pesanan Masuk" screen works in sub-orders, not orders (API doc 4).
  Future<List<SubOrder>> getSubOrders() async {
    final orders = await getOrders();
    return orders.expand((order) => order.subOrders).toList(growable: false);
  }

  /// MENUNGGU_KONFIRMASI -> DIKONFIRMASI.
  Future<String> confirm(int subOrderId) async {
    final envelope = await postRequest(ApiEndpoints.subOrderConfirm(subOrderId));
    return envelope.map['status']?.toString() ?? '';
  }

  /// [reason] must come from [RejectReason.all] — anything else is rejected
  /// with `422 INVALID_REASON`. Costs the store 2 score points, and a confirmed
  /// sub-order holding a custom item cannot be rejected at all
  /// (`409 CUSTOM_ITEM_LOCKED`).
  Future<String> reject(int subOrderId, {required String reason}) async {
    final envelope = await postRequest(
      ApiEndpoints.subOrderReject(subOrderId),
      body: <String, dynamic>{'reason': reason},
    );
    return envelope.map['status']?.toString() ?? '';
  }

  /// DIKONFIRMASI -> BERJALAN. Must be called before a shipment can be created.
  Future<String> readyToShip(int subOrderId) async {
    final envelope =
        await postRequest(ApiEndpoints.subOrderReadyToShip(subOrderId));
    return envelope.map['status']?.toString() ?? '';
  }
}
