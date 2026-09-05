import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/order/order_model.dart';
import '../../../../../core/domain/repositories/order_repository.dart';
import '../../../../../di/injector.dart';

part 'orders_state.dart';

/// Incoming orders.
///
/// Works in **sub-orders**, not orders: an order is the buyer's payment unit
/// and may span several stores, while the sub-order is this store's part and
/// the thing it confirms, rejects and ships (API doc 4).
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(const OrdersLoadInProgress());

  static OrdersCubit get(BuildContext context) => BlocProvider.of(context);

  final OrderRepository _orderRepository = injector<OrderRepository>();

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) emit(const OrdersLoadInProgress());

    final result = await _orderRepository.getSubOrders();
    if (isClosed) return;

    final filter = switch (state) {
      OrdersLoadSuccess(:final filter) => filter,
      _ => OrderFilter.needsAction,
    };

    switch (result) {
      case DataSuccess<List<SubOrder>>(:final value):
        emit(OrdersLoadSuccess(subOrders: _sorted(value), filter: filter));
      case DataEmpty<List<SubOrder>>():
        emit(OrdersLoadSuccess(subOrders: const <SubOrder>[], filter: filter));
      case DataFailed<List<SubOrder>>(:final failure):
        emit(OrdersLoadFailure(failure));
      case DataLoading<List<SubOrder>>():
        break;
    }
  }

  void setFilter(OrderFilter filter) {
    final current = state;
    if (current is! OrdersLoadSuccess) return;
    emit(current.copyWith(filter: filter));
  }

  Future<DataError?> confirm(int subOrderId) =>
      _act(subOrderId, () => _orderRepository.confirm(subOrderId));

  /// [reason] must come from [RejectReason.all]; costs the store 2 score points.
  Future<DataError?> reject(int subOrderId, String reason) =>
      _act(subOrderId, () => _orderRepository.reject(subOrderId, reason: reason));

  Future<DataError?> readyToShip(int subOrderId) =>
      _act(subOrderId, () => _orderRepository.readyToShip(subOrderId));

  Future<DataError?> _act(
    int subOrderId,
    Future<DataState<String>> Function() action,
  ) async {
    final current = state;
    if (current is OrdersLoadSuccess) {
      emit(current.copyWith(busySubOrderId: subOrderId));
    }

    final result = await action();
    if (isClosed) return null;

    if (result is DataFailed<String>) {
      if (current is OrdersLoadSuccess) emit(current.copyWith(clearBusy: true));
      return result.failure;
    }

    await load(showSpinner: false);
    return null;
  }

  /// Anything needing action first, then by deadline — the row most likely to
  /// cost money if ignored sits at the top.
  static List<SubOrder> _sorted(List<SubOrder> subOrders) {
    final sorted = subOrders.toList();
    sorted.sort((a, b) {
      final aUrgent = a.awaitingConfirmation ? 0 : 1;
      final bUrgent = b.awaitingConfirmation ? 0 : 1;
      if (aUrgent != bUrgent) return aUrgent.compareTo(bUrgent);

      final aDeadline = a.activeDeadline;
      final bDeadline = b.activeDeadline;
      if (aDeadline != null && bDeadline != null) {
        return aDeadline.compareTo(bDeadline);
      }
      if (aDeadline != null) return -1;
      if (bDeadline != null) return 1;
      return b.id.compareTo(a.id);
    });
    return sorted;
  }
}
