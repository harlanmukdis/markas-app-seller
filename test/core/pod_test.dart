import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/shipment/shipment.dart';
import 'package:navy_wear/core/domain/model/order/order_model.dart';
import 'package:navy_wear/features/seller_orders/presentation/cubits/pod_cubit/pod_cubit.dart';
import 'package:navy_wear/features/seller_orders/presentation/cubits/sub_order_detail_cubit/sub_order_detail_cubit.dart';

/// Payloads copied from `GET /shipments/4` on the running backend.
void main() {
  group('ShipmentItem.fromJson', () {
    test('reads the line id POD has to quote back, and the string decimals',
        () {
      // `id` here is the shipment_item_id that `pod_items` keys on — not the
      // sub_order_item_id, which is a different number on the same row.
      final item = ShipmentItem.fromJson(<String, dynamic>{
        'id': '4',
        'shipment_id': '4',
        'sub_order_item_id': '6',
        'qty': '40.0000',
        'actual_qty_received': null,
      });

      expect(item.id, 4);
      expect(item.subOrderItemId, 6);
      expect(item.qty, 40);
      expect(item.actualQtyReceived, isNull);
      expect(item.hasShortfall, isFalse);
    });

    test('a short delivery is visible once POD has been recorded', () {
      final item = ShipmentItem.fromJson(<String, dynamic>{
        'id': '4',
        'qty': '40.0000',
        'actual_qty_received': '38.5000',
      });

      expect(item.actualQtyReceived, 38.5);
      expect(item.hasShortfall, isTrue);
    });

    test('receiving the full quantity is not a shortfall', () {
      final item = ShipmentItem.fromJson(<String, dynamic>{
        'id': '4',
        'qty': '40.0000',
        'actual_qty_received': '40.0000',
      });

      expect(item.hasShortfall, isFalse);
    });
  });

  group('PodResult', () {
    test('reports the automatic bulk refund the payout will be short by', () {
      final result = PodResult.fromJson(<String, dynamic>{
        'bulk_tolerance_refund': '75000.00',
      });

      expect(result.bulkToleranceRefund, 75000);
      expect(result.hadToleranceRefund, isTrue);
    });

    test('a zero refund is not a refund', () {
      // The server sends 0 rather than omitting the key, and announcing
      // "Rp 0 dikembalikan" would read as a bug to the store.
      expect(
        PodResult.fromJson(<String, dynamic>{'bulk_tolerance_refund': '0'})
            .hadToleranceRefund,
        isFalse,
      );
      expect(
        PodResult.fromJson(<String, dynamic>{}).hadToleranceRefund,
        isFalse,
      );
    });
  });

  group('PodReady', () {
    const shipment = Shipment(
      id: 4,
      items: <ShipmentItem>[
        ShipmentItem(id: 4, subOrderItemId: 6, qty: 40),
      ],
    );

    test('names the line from the sub-order, which the shipment omits', () {
      // `GET /shipments/{id}` returns lines with no product name at all, so
      // without this the driver signs for "Barang #6".
      const state = PodReady(
        shipment: shipment,
        itemNames: <int, String>{6: 'Semen Padang 50 kg'},
        itemUnits: <int, String>{6: 'sak'},
      );

      expect(state.nameFor(shipment.items.first), 'Semen Padang 50 kg');
      expect(state.unitFor(shipment.items.first), 'sak');
    });

    test('falls back to the line id before the names arrive', () {
      const state = PodReady(shipment: shipment);

      expect(state.nameFor(shipment.items.first), 'Barang #6');
      expect(state.unitFor(shipment.items.first), '');
    });
  });

  group('SubOrderDetailLoadSuccess.remainingFor', () {
    const item = SubOrderItem(id: 6, qty: 40);
    const subOrder = SubOrder(id: 6, items: <SubOrderItem>[item]);

    test('a shipment whose lines are unknown must not read as nothing sent',
        () {
      // `GET /shipments` returns no `items[]` at all. Treating that as "zero
      // shipped" made the screen offer to ship the same 40 sacks again.
      const state = SubOrderDetailLoadSuccess(
        subOrder: subOrder,
        shipments: <Shipment>[Shipment(id: 4, subOrderId: 6)],
      );

      expect(state.remainingFor(item), 40);
    });

    test('subtracts what the detail says was already shipped', () {
      const state = SubOrderDetailLoadSuccess(
        subOrder: subOrder,
        shipments: <Shipment>[
          Shipment(
            id: 4,
            subOrderId: 6,
            items: <ShipmentItem>[
              ShipmentItem(id: 4, subOrderItemId: 6, qty: 40),
            ],
          ),
        ],
      );

      expect(state.remainingFor(item), 0);
      expect(state.hasUnshippedItems, isFalse);
    });

    test('a partial shipment leaves the rest available', () {
      const state = SubOrderDetailLoadSuccess(
        subOrder: subOrder,
        shipments: <Shipment>[
          Shipment(
            id: 4,
            subOrderId: 6,
            items: <ShipmentItem>[
              ShipmentItem(id: 4, subOrderItemId: 6, qty: 15),
            ],
          ),
        ],
      );

      expect(state.remainingFor(item), 25);
      expect(state.hasUnshippedItems, isTrue);
    });
  });
}
