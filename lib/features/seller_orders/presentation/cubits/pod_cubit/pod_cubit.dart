import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/order/order_model.dart';
import '../../../../../core/domain/model/shipment/shipment.dart';
import '../../../../../core/domain/repositories/order_repository.dart';
import '../../../../../core/domain/repositories/shipment_repository.dart';
import '../../../../../di/injector.dart';

part 'pod_state.dart';

/// Backs the field screen where a delivery is signed for.
///
/// It loads the shipment on its own rather than taking one from the order
/// screen, because `GET /shipments` omits `items[]` — and the lines are the
/// whole point: declaring what actually arrived is what protects the store
/// from a "kurang kirim" dispute later.
class PodCubit extends Cubit<PodState> {
  PodCubit(this.shipmentId) : super(const PodLoadInProgress());

  static PodCubit get(BuildContext context) => BlocProvider.of(context);

  final int shipmentId;

  final ShipmentRepository _shipmentRepository = injector<ShipmentRepository>();
  final OrderRepository _orderRepository = injector<OrderRepository>();

  Future<void> load() async {
    emit(const PodLoadInProgress());

    final result = await _shipmentRepository.getShipment(shipmentId);
    if (isClosed) return;

    if (result is DataFailed<Shipment>) {
      emit(PodLoadFailure(result.failure));
      return;
    }
    if (result is! DataSuccess<Shipment>) {
      emit(
        const PodLoadFailure(
          DataError(
            code: DataErrorCode.notFound,
            message: 'Pengiriman tidak ditemukan.',
          ),
        ),
      );
      return;
    }

    final shipment = result.value;
    emit(PodReady(shipment: shipment));

    final subOrderId = shipment.subOrderId;
    if (subOrderId == null) return;

    // Names land after the first paint; the quantities are already usable.
    final subOrder = await _orderRepository.getSubOrder(subOrderId);
    if (isClosed) return;
    final current = state;
    if (current is! PodReady || subOrder is! DataSuccess<SubOrder>) return;

    emit(
      current.copyWith(
        itemNames: <int, String>{
          for (final item in subOrder.value.items)
            if (item.itemNameSnapshot != null) item.id: item.itemNameSnapshot!,
        },
        itemUnits: <int, String>{
          for (final item in subOrder.value.items)
            if (item.unitNameSnapshot != null) item.id: item.unitNameSnapshot!,
        },
      ),
    );
  }

  /// [podItems] may be empty — send it only when the store actually counted,
  /// because an `actual_qty_received` equal to the shipped quantity is not the
  /// same statement as declining to declare one.
  Future<PodOutcome> submit({
    required String photoUrl,
    required String receiverName,
    String? signatureUrl,
    List<PodItem> podItems = const <PodItem>[],
  }) async {
    final current = state;
    if (current is PodReady) emit(current.copyWith(isSubmitting: true));

    final result = await _shipmentRepository.recordPod(
      shipmentId,
      photoUrl: photoUrl,
      receiverName: receiverName,
      signatureUrl: signatureUrl,
      podItems: podItems,
    );
    if (isClosed) return const PodOutcome();

    if (result is DataFailed<PodResult>) {
      final latest = state;
      if (latest is PodReady) emit(latest.copyWith(isSubmitting: false));
      return PodOutcome(error: result.failure);
    }

    final pod = result is DataSuccess<PodResult> ? result.value : null;
    final counted =
        podItems.isEmpty ? false : !await _countsWereStored(podItems);
    if (isClosed) return const PodOutcome();

    final latest = state;
    if (latest is PodReady) emit(latest.copyWith(isSubmitting: false));
    return PodOutcome(result: pod, countsDropped: counted);
  }

  /// The server accepts `pod_items` and answers 200 whether or not it keeps
  /// them — verified live with a plain request: a declared shortfall on a
  /// non-bulk line came back as `actual_qty_received: null`. Telling the store
  /// its count was recorded when it was not is worse than saying nothing, so
  /// read the shipment back and check.
  Future<bool> _countsWereStored(List<PodItem> sent) async {
    final result = await _shipmentRepository.getShipment(shipmentId);
    if (result is! DataSuccess<Shipment>) return true;

    final stored = <int, double?>{
      for (final item in result.value.items) item.id: item.actualQtyReceived,
    };
    return sent.every(
      (item) => stored[item.shipmentItemId] == item.actualQtyReceived,
    );
  }
}

/// What the POD screen has to report afterwards: the automatic refund the
/// server applied, and whether the counts it was given actually stuck.
class PodOutcome {
  const PodOutcome({this.error, this.result, this.countsDropped = false});

  final DataError? error;
  final PodResult? result;

  /// True when a declared quantity did not survive the round trip.
  final bool countsDropped;
}
