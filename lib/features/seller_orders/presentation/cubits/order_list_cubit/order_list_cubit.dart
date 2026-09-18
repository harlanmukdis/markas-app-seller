import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/order/order.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/order_repository.dart';
import '../../../../../di/injector.dart';

part 'order_list_state.dart';

/// The store's incoming orders.
///
/// The filter is sent to the server rather than applied locally, because unlike
/// the catalogue this list is paged and long — filtering a single page would
/// show a fraction of what matches.
class OrderListCubit extends Cubit<OrderListState> {
  OrderListCubit() : super(const OrderListInProgress());

  static OrderListCubit get(BuildContext context) => BlocProvider.of(context);

  final OrderRepository _orders = injector<OrderRepository>();
  final AuthRepository _auth = injector<AuthRepository>();

  OrderFilter _filter = OrderFilter.needsAction;

  Future<void> load({OrderFilter? filter}) async {
    if (isClosed) return;
    if (filter != null) _filter = filter;

    final storeId = _auth.activeStoreId;
    if (storeId == null) {
      emit(const OrderListNoStore());
      return;
    }

    emit(const OrderListInProgress());

    // "Needs action" is not a status the server knows, so it is assembled from
    // the three statuses that each mean "the seller's move".
    final statuses = _filter.statuses;
    final collected = <Order>[];

    for (final status in statuses) {
      final result = await _orders.getStoreOrders(storeId, status: status);
      if (isClosed) return;

      switch (result) {
        case DataSuccess<List<Order>>(:final value):
          collected.addAll(value);
        case DataFailed<List<Order>>(:final failure):
          emit(OrderListFailure(failure));
          return;
        default:
          break;
      }
    }

    collected.sort((a, b) {
      final left = a.createdAt;
      final right = b.createdAt;
      if (left == null || right == null) return b.id.compareTo(a.id);
      return right.compareTo(left);
    });

    emit(OrderListLoaded(orders: collected, filter: _filter));
  }

  Future<void> setFilter(OrderFilter filter) => load(filter: filter);
}
