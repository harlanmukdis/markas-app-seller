import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/order/order.dart';
import '../../../../../core/domain/repositories/order_repository.dart';
import '../../../../../di/injector.dart';

part 'order_detail_state.dart';

/// One order, and the seller's moves on it.
///
/// Every action checks the order's own `can*` flag first and refuses locally
/// rather than letting the server decide. That is not defensive politeness: an
/// out-of-order transition comes back as **HTTP 200 with an HTML exception
/// page**, which no error handler can turn into something a seller would
/// understand.
class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit(this.orderId) : super(const OrderDetailInProgress());

  static OrderDetailCubit get(BuildContext context) => BlocProvider.of(context);

  final int orderId;

  final OrderRepository _orders = injector<OrderRepository>();

  Future<void> load() async {
    if (isClosed) return;
    emit(const OrderDetailInProgress());

    final result = await _orders.getOrder(orderId);
    if (isClosed) return;

    switch (result) {
      case DataSuccess<Order>(:final value):
        emit(OrderDetailLoaded(value));
        await _loadTracking();
      case DataFailed<Order>(:final failure):
        emit(OrderDetailFailure(failure));
      default:
        emit(const OrderDetailFailure(
          DataError(
            code: DataErrorCode.unexpected,
            message: 'Pesanan tidak ditemukan.',
          ),
        ));
    }
  }

  /// Only worth asking once the order has actually shipped — before that the
  /// endpoint answers null, and a null tracking row is not news.
  Future<void> _loadTracking() async {
    final current = state;
    if (current is! OrderDetailLoaded) return;
    if (current.order.status != OrderStatus.shipped &&
        current.order.status != OrderStatus.delivered) {
      return;
    }

    final result = await _orders.getTracking(orderId);
    if (isClosed) return;
    if (result is DataSuccess<OrderShipment>) {
      final latest = state;
      if (latest is OrderDetailLoaded) {
        emit(latest.copyWith(shipment: result.value));
      }
    }
  }

  Future<DataError?> accept() => _act(
        guard: (order) => order.canAccept,
        refusal: 'Pesanan ini belum dibayar, jadi belum bisa diproses.',
        action: () => _orders.accept(orderId),
      );

  Future<DataError?> pack() => _act(
        guard: (order) => order.canPack,
        refusal: 'Pesanan harus diterima dulu sebelum ditandai siap kirim.',
        action: () => _orders.pack(orderId),
      );

  Future<DataError?> ship({
    required String courierCode,
    required String awbNumber,
  }) =>
      _act(
        guard: (order) => order.canShip,
        refusal: 'Pesanan harus dikemas dulu sebelum diserahkan ke kurir.',
        action: () => _orders.ship(
          orderId,
          courierCode: courierCode,
          awbNumber: awbNumber,
        ),
      );

  Future<DataError?> cancel(String reason) => _act(
        guard: (order) => order.canCancel,
        refusal: 'Pesanan yang sudah diproses tidak bisa dibatalkan di sini.',
        action: () => _orders.cancel(orderId, reason: reason),
      );

  Future<DataError?> resolveRefund({required bool approve}) => _act(
        guard: (order) => order.canResolveRefund,
        refusal: 'Tidak ada pengajuan refund yang menunggu keputusan.',
        action: () {
          final current = state as OrderDetailLoaded;
          final refundId = current.order.refund!.id;
          return approve
              ? _orders.approveRefund(orderId, refundId)
              : _orders.rejectRefund(orderId, refundId);
        },
      );

  Future<DataError?> _act({
    required bool Function(Order order) guard,
    required String refusal,
    required Future<DataState<Order>> Function() action,
  }) async {
    final current = state;
    if (current is! OrderDetailLoaded) return null;

    if (!guard(current.order)) {
      return DataError(
        code: 'ORDER_STATE_INVALID',
        message: refusal,
        details: <String, dynamic>{'status': current.order.status},
      );
    }

    emit(current.copyWith(isBusy: true));
    final result = await action();
    if (isClosed) return null;

    switch (result) {
      case DataSuccess<Order>(:final value):
        emit(OrderDetailLoaded(value, shipment: current.shipment));
        await _loadTracking();
        return null;
      case DataFailed<Order>(:final failure):
        emit(current.copyWith(isBusy: false));
        return failure;
      default:
        emit(current.copyWith(isBusy: false));
        await load();
        return null;
    }
  }
}
