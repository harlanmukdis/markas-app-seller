import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/order/order.dart';

/// Payloads captured from the running marketplace API.
void main() {
  Map<String, dynamic> row({String status = 'pending'}) => <String, dynamic>{
        'id': '135',
        'order_number': 'ORD-20260915-0001',
        'checkout_session_id': 'ca9128bd-dd10-4c45-bf01-b95e0c31eddc',
        'buyer_id': '9',
        'store_id': '1',
        'warehouse_id': '1',
        'status': status,
        'subtotal': '75000.00',
        'shipping_cost': '17000.00',
        'discount_total': '0.00',
        'grand_total': '92000.00',
        'courier_code': null,
        'courier_service': null,
        'tracking_number': null,
        'shipping_address_snapshot':
            '{"recipient_name":"Buyer Probe","city":"Jakarta Selatan",'
                '"province":"DKI Jakarta","full_address":"Jl. Pembeli 1",'
                '"postal_code":"12345"}',
        'payment_deadline': '2026-09-16 22:38:21',
        'created_at': '2026-09-15 22:38:21',
      };

  group('Order.fromJson', () {
    test('reads a list row', () {
      final order = Order.fromJson(row());

      expect(order.id, 135);
      expect(order.orderNumber, 'ORD-20260915-0001');
      expect(order.grandTotal, 92000);
      expect(order.shippingCost, 17000);
      expect(order.trackingNumber, isNull);
      // The list payload carries no items — that is not "an order with nothing
      // in it".
      expect(order.items, isEmpty);
    });

    test('decodes the address snapshot, which arrives as a JSON string', () {
      final order = Order.fromJson(row());

      expect(order.recipientName, 'Buyer Probe');
      expect(order.shippingCity, 'Jakarta Selatan');
    });

    test('reads items, history and the refund from the detail payload', () {
      final order = Order.fromJson(row(status: 'refund_requested')
        ..addAll(<String, dynamic>{
          'items': <dynamic>[
            <String, dynamic>{
              'id': '135',
              'product_variant_id': '1',
              'product_name_snapshot': 'Kopi Arabika Gayo 250g',
              'variant_options_snapshot': '{"ukuran":"250g"}',
              'price_snapshot': '75000.00',
              'quantity': '2',
              'subtotal': '150000.00',
            },
          ],
          'status_history': <dynamic>[
            <String, dynamic>{
              'id': '149',
              'from_status': null,
              'to_status': 'pending',
              'notes': null,
              'created_at': '2026-09-15 22:38:21',
            },
          ],
          'refund': <String, dynamic>{
            'id': '7',
            'amount': '92000.00',
            'reason': 'Barang tidak sesuai',
            'status': 'requested',
          },
        }));

      expect(order.items.single.productName, 'Kopi Arabika Gayo 250g');
      expect(order.items.single.optionsLabel, '250g');
      expect(order.itemCount, 2);
      expect(order.statusHistory.single.fromStatus, isNull);
      // The refund id lives here and nowhere else the seller can reach.
      expect(order.refund!.id, 7);
      expect(order.refund!.amount, 92000);
      expect(order.canResolveRefund, isTrue);
    });
  });

  group('Order action gating', () {
    // The server answers an out-of-order transition with HTTP 200 and an HTML
    // exception page, so these flags are the only thing standing between a
    // seller and an unreadable failure.
    test('a pending order can only be cancelled', () {
      final order = Order.fromJson(row(status: 'pending'));

      expect(order.isAwaitingPayment, isTrue);
      expect(order.canAccept, isFalse);
      expect(order.canPack, isFalse);
      expect(order.canShip, isFalse);
      expect(order.canCancel, isTrue);
      expect(order.needsAction, isFalse);
    });

    test('a paid order is the one waiting to be accepted', () {
      final order = Order.fromJson(row(status: 'paid'));

      expect(order.canAccept, isTrue);
      expect(order.canPack, isFalse);
      expect(order.canCancel, isTrue);
      expect(order.needsAction, isTrue);
    });

    test('processed then packed each unlock exactly one next move', () {
      final processed = Order.fromJson(row(status: 'processed'));
      expect(processed.canPack, isTrue);
      expect(processed.canAccept, isFalse);
      expect(processed.canShip, isFalse);
      // Cancellation closes once the order is being worked on.
      expect(processed.canCancel, isFalse);

      final packed = Order.fromJson(row(status: 'packed'));
      expect(packed.canShip, isTrue);
      expect(packed.canPack, isFalse);
      expect(packed.canCancel, isFalse);
    });

    test('a shipped order leaves nothing for the seller to do', () {
      final order = Order.fromJson(row(status: 'shipped'));

      expect(order.needsAction, isFalse);
      expect(order.canAccept, isFalse);
      expect(order.canShip, isFalse);
      expect(order.canCancel, isFalse);
    });

    test('a refund with no refund row cannot be resolved', () {
      // refund_requested but the payload carried no refund object — approve and
      // reject both need an id that is not there.
      final order = Order.fromJson(row(status: 'refund_requested'));

      expect(order.refund, isNull);
      expect(order.canResolveRefund, isFalse);
    });
  });

  group('OrderShipment.fromJson', () {
    test('reads the shipment row', () {
      final shipment = OrderShipment.fromJson(<String, dynamic>{
        'id': '3',
        'order_id': '135',
        'courier_code': 'jne',
        'service_type': 'reguler',
        'awb_number': 'JNE1234567890',
        'status': 'picked_up',
        'shipped_at': '2026-09-15 23:10:00',
      });

      expect(shipment.awbNumber, 'JNE1234567890');
      expect(shipment.serviceType, 'reguler');
      expect(shipment.shippedAt, DateTime(2026, 9, 15, 23, 10));
    });
  });
}
