import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/order/order_model.dart';
import '../../../../../core/domain/model/shipment/shipment.dart';
import '../../../../../core/domain/repositories/order_repository.dart';
import '../../../../../core/domain/repositories/shipment_repository.dart';
import '../../../../../di/injector.dart';

part 'sub_order_detail_state.dart';

/// One sub-order and the shipments under it — the screen where the fulfilment
/// chain actually runs: ready_to_ship -> create shipment -> process -> ship ->
/// POD.
class SubOrderDetailCubit extends Cubit<SubOrderDetailState> {
  SubOrderDetailCubit(this.subOrderId)
      : super(const SubOrderDetailLoadInProgress());

  static SubOrderDetailCubit get(BuildContext context) =>
      BlocProvider.of(context);

  final int subOrderId;

  final OrderRepository _orderRepository = injector<OrderRepository>();
  final ShipmentRepository _shipmentRepository = injector<ShipmentRepository>();

  Future<void> load({bool showSpinner = true}) async {
    if (showSpinner) emit(const SubOrderDetailLoadInProgress());

    final results = await Future.wait(<Future<Object>>[
      _orderRepository.getSubOrder(subOrderId),
      _shipmentRepository.getShipments(),
    ]);

    if (isClosed) return;

    final subOrderResult = results[0] as DataState<SubOrder>;
    if (subOrderResult is DataFailed<SubOrder>) {
      emit(SubOrderDetailLoadFailure(subOrderResult.failure));
      return;
    }
    if (subOrderResult is! DataSuccess<SubOrder>) {
      emit(
        const SubOrderDetailLoadFailure(
          DataError(
            code: DataErrorCode.notFound,
            message: 'Sub-pesanan tidak ditemukan.',
          ),
        ),
      );
      return;
    }

    final subOrder = subOrderResult.value;
    final allShipments = switch (results[1] as DataState<List<Shipment>>) {
      DataSuccess<List<Shipment>>(:final value) => value,
      _ => const <Shipment>[],
    };

    emit(
      SubOrderDetailLoadSuccess(
        subOrder: subOrder,
        // The shipments endpoint is not filtered by sub-order, so narrow it
        // here; fall back to whatever the sub-order itself carried.
        shipments: allShipments
                .where((shipment) => shipment.subOrderId == subOrderId)
                .toList()
                .let((filtered) =>
                    filtered.isEmpty ? subOrder.shipments : filtered),
      ),
    );
  }

  Future<DataError?> readyToShip() =>
      _act(() => _orderRepository.readyToShip(subOrderId));

  /// The sub-order must already be BERJALAN. Items may cover only part of it —
  /// each shipment pays out on its own.
  Future<DataError?> createShipment({
    required String shippingMethod,
    required List<ShipmentLine> items,
    String? fleetTypeCode,
    int? zoneId,
    int? shippingCost,
  }) =>
      _act(() => _shipmentRepository.createShipment(
            subOrderId: subOrderId,
            shippingMethod: shippingMethod,
            items: items,
            fleetTypeCode: fleetTypeCode,
            zoneId: zoneId,
            shippingCost: shippingCost,
          ));

  Future<DataError?> processShipment(int shipmentId) =>
      _act(() => _shipmentRepository.process(shipmentId));

  /// Deducts stock and issues the delivery note.
  Future<DataError?> shipShipment(int shipmentId) =>
      _act(() => _shipmentRepository.ship(shipmentId));

  Future<DataError?> recordPod(
    int shipmentId, {
    required String photoUrl,
    required String receiverName,
  }) =>
      _act(() => _shipmentRepository.recordPod(
            shipmentId,
            photoUrl: photoUrl,
            receiverName: receiverName,
          ));

  Future<DataError?> failDelivery(int shipmentId) =>
      _act(() => _shipmentRepository.failDelivery(shipmentId));

  Future<DataError?> _act(Future<DataState<Object>> Function() action) async {
    final current = state;
    if (current is SubOrderDetailLoadSuccess) {
      emit(current.copyWith(isBusy: true));
    }

    final result = await action();
    if (isClosed) return null;

    if (result is DataFailed<Object>) {
      if (current is SubOrderDetailLoadSuccess) {
        emit(current.copyWith(isBusy: false));
      }
      return result.failure;
    }

    await load(showSpinner: false);
    return null;
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T value) transform) => transform(this);
}
