import '../../../../../config/network/api_endpoints.dart';
import '../../../../../config/network/api_exception.dart';
import '../../../../data_state.dart';
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

  /// The store's sub-orders — what the "Pesanan Masuk" screen actually shows.
  ///
  /// `GET /orders` does not return `sub_orders[]` for a seller. It returns one
  /// flat row per sub-order, joining the parent order's columns alongside, so
  /// each row is parsed directly as a [SubOrder]. Reading `sub_orders` from it
  /// yields an empty list and a screen that looks like there are no orders.
  Future<List<SubOrder>> getSubOrders() async {
    final envelope = await getRequest(ApiEndpoints.orders);
    return envelope
        .listAt('orders')
        .map(SubOrder.fromFlatOrderRow)
        .toList(growable: false);
  }

  /// Finds the real sub-order behind a flat `GET /orders` row.
  ///
  /// The list row's `id` cannot be trusted (see [SubOrder.fromFlatOrderRow]),
  /// so this reads the parent order — whose `sub_orders[]` carry unambiguous
  /// ids — and matches on `sub_order_no`, which is unique. Acting on the wrong
  /// sub-order would confirm or cancel somebody else's line.
  Future<SubOrder> resolveSubOrder(SubOrder listRow) async {
    if (!listRow.idIsAmbiguous) return listRow;

    final orderId = listRow.orderId;
    if (orderId == null) return listRow;

    final order = await getOrder(orderId);
    final subOrderNo = listRow.subOrderNo;

    for (final candidate in order.subOrders) {
      if (subOrderNo != null && candidate.subOrderNo == subOrderNo) {
        return candidate;
      }
    }

    // No number to match on: fall back to the only sub-order, if there is one.
    // With several, guessing is worse than failing loudly.
    if (order.subOrders.length == 1) return order.subOrders.single;

    throw ApiException(
      code: DataErrorCode.notFound,
      message: 'Sub-pesanan ${subOrderNo ?? listRow.id} tidak ditemukan pada '
          'order $orderId.',
    );
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
