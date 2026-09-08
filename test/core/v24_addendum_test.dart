import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/catalog/offer.dart';
import 'package:navy_wear/core/domain/model/finance/finance.dart';
import 'package:navy_wear/core/domain/model/returns/return_model.dart';
import 'package:navy_wear/core/domain/model/shipment/shipment.dart';

/// Addendum 1.2 (v2.4). Payloads captured from the running backend.
void main() {
  group('Shipment (v2.4 fields)', () {
    // Captured from GET /shipments.
    const payload = <String, dynamic>{
      'id': '4',
      'shipment_no': 'SHP-260908-35623E15',
      'sub_order_id': '6',
      'status': 'BALIK_KE_TOKO',
      'shipping_method': 'KURIR_3PL',
      'shipping_cost': '100000.00',
      'delivery_attempt_count': '3',
      'failure_reason_code': 'KENDALA_AKSES_LINGKUNGAN',
      'packaging_deposit_amount': '150000.00',
      'packaging_returned_confirmed_at': null,
      'storage_fee_accrued': '50000.00',
      'returned_at': '2026-09-08 10:00:00',
      'created_date': '2026-09-08 17:48:04',
    };

    test('reads the new field-constraint columns', () {
      final shipment = Shipment.fromJson(payload);

      expect(shipment.shipmentNo, 'SHP-260908-35623E15');
      expect(shipment.failureReasonCode, FailureReason.kendalaAksesLingkungan);
      expect(shipment.packagingDepositAmount, 150000);
      expect(shipment.storageFeeAccrued, 50000);
      expect(shipment.returnedAt, isNotNull);
    });

    test('offers restock only once the goods are back', () {
      expect(Shipment.fromJson(payload).canRestock, isTrue);
      expect(
        Shipment.fromJson(<String, dynamic>{...payload, 'status': 'DIKIRIM'})
            .canRestock,
        isFalse,
      );
    });

    test('a held deposit is releasable, a released one is not', () {
      final held = Shipment.fromJson(payload);
      expect(held.hasPackagingDeposit, isTrue);
      expect(held.canReleasePackagingDeposit, isTrue);

      final released = Shipment.fromJson(<String, dynamic>{
        ...payload,
        'packaging_returned_confirmed_at': '2026-09-09 08:00:00',
      });
      expect(released.packagingDepositReleased, isTrue);
      expect(released.canReleasePackagingDeposit, isFalse);
    });

    test('a shipment without a deposit offers nothing to release', () {
      final none = Shipment.fromJson(<String, dynamic>{
        ...payload,
        'packaging_deposit_amount': '0.00',
      });

      expect(none.hasPackagingDeposit, isFalse);
      expect(none.canReleasePackagingDeposit, isFalse);
    });
  });

  group('FailureReason', () {
    test('is a closed list and explains the operational one', () {
      expect(FailureReason.all, hasLength(5));
      expect(
        FailureReason.label('KENDALA_AKSES_LINGKUNGAN'),
        'Kendala akses lingkungan',
      );
      // This is the reason the platform acts on, so it gets a hint; the others
      // are self-explanatory.
      expect(FailureReason.hint('KENDALA_AKSES_LINGKUNGAN'), isNotNull);
      expect(FailureReason.hint('BUYER_TIDAK_ADA'), isNull);
    });
  });

  group('PodResult', () {
    test('reports an automatic bulk-tolerance refund', () {
      final pod = PodResult.fromJson(<String, dynamic>{
        'bulk_tolerance_refund': '47500.00',
      });

      expect(pod.hadToleranceRefund, isTrue);
      expect(pod.bulkToleranceRefund, 47500);
    });

    test('a full delivery refunds nothing', () {
      final pod = PodResult.fromJson(<String, dynamic>{
        'bulk_tolerance_refund': null,
      });

      expect(pod.hadToleranceRefund, isFalse);
    });

    test('a PodItem serialises the field names the server expects', () {
      expect(
        const PodItem(shipmentItemId: 9, actualQtyReceived: 19.4).toJson(),
        <String, dynamic>{
          'shipment_item_id': 9,
          'actual_qty_received': 19.4,
        },
      );
    });
  });

  group('SellerFaultReason', () {
    test('flags the two reasons the backend always charges to the store', () {
      // Sending fault: BUYER for these is ignored server-side, so the UI must
      // not offer the choice.
      expect(SellerFaultReason.isAlwaysSellerFault('SHADING_MISMATCH'), isTrue);
      expect(
        SellerFaultReason.isAlwaysSellerFault('SNI_TOLERANCE_MISMATCH'),
        isTrue,
      );
      expect(SellerFaultReason.isAlwaysSellerFault('RUSAK_PECAH'), isFalse);
      expect(SellerFaultReason.explanation('RUSAK_PECAH'), isNull);
    });
  });

  group('Offer sample variant', () {
    test('reads is_sample and the full-size listing it points at', () {
      final sample = Offer.fromJson(<String, dynamic>{
        'id': '80',
        'status': 'ACTIVE',
        'is_sample': '1',
        'sample_of_offer_id': '65',
      });

      expect(sample.isSample, isTrue);
      expect(sample.sampleOfOfferId, 65);
    });

    test('a normal offer is not a sample', () {
      expect(
        Offer.fromJson(<String, dynamic>{'id': '65', 'is_sample': '0'}).isSample,
        isFalse,
      );
    });
  });

  group('CommissionRate', () {
    // Captured from GET /commission-rates.
    const payload = <String, dynamic>{
      'id': '5',
      'category_id': '5',
      'category_name': 'Baja Ringan',
      'rate_percent': '3.00',
      'cap_amount': '500000.00',
      'effective_from': '2026-01-01',
      'effective_to': null,
    };

    test('reads the rate and its cap', () {
      final rate = CommissionRate.fromJson(payload);

      expect(rate.categoryName, 'Baja Ringan');
      expect(rate.ratePercent, 3);
      expect(rate.capAmount, 500000);
      expect(rate.rateLabel, '3%');
    });

    test('an open-ended rate is active; a lapsed one is not', () {
      expect(CommissionRate.fromJson(payload).isActive, isTrue);

      final lapsed = CommissionRate.fromJson(<String, dynamic>{
        ...payload,
        'effective_to': '2026-01-31',
      });
      expect(lapsed.isActive, isFalse);
    });
  });
}
