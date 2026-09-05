import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/returns/return_model.dart';

/// Captured from `GET /returns` on the running backend. The field names here
/// differ from the ones in the API documentation — `seller_response_deadline`
/// rather than `deadline_toko_jawab`, and so on — which silently suppressed
/// every countdown until it was checked against a real response.
void main() {
  const Map<String, dynamic> payload = <String, dynamic>{
    'id': '1',
    'return_no': 'RET-260905-06696EA7',
    'shipment_id': '1',
    'buyer_id': '13',
    'reason': 'RUSAK_PECAH',
    'qty_returned': '4.0000',
    'evidence_photos_json':
        '["https:\\/\\/contoh.test\\/bongkar1.jpg","https:\\/\\/contoh.test\\/bongkar2.jpg"]',
    'status': 'DIAJUKAN',
    'seller_response_deadline': '2026-09-07 17:29:00',
    'seller_responded_at': null,
    'return_courier_type': null,
    'pickup_deadline': null,
    'seller_inspect_deadline': null,
    'created_at': '2026-09-05 23:06:58',
  };

  group('ReturnModel.fromJson', () {
    test('reads the deadline the server actually sends', () {
      final entry = ReturnModel.fromJson(payload);

      expect(entry.sellerResponseDeadline, isNotNull);
      expect(entry.sellerResponseDeadline!.day, 7);
      expect(entry.sellerResponseDeadline!.hour, 17);
    });

    test('surfaces the running clock through activeDeadline', () {
      final entry = ReturnModel.fromJson(payload);

      expect(entry.awaitingResponse, isTrue);
      expect(entry.activeDeadline, entry.sellerResponseDeadline);
    });

    test('switches to the inspection clock once the goods are back', () {
      final entry = ReturnModel.fromJson(<String, dynamic>{
        ...payload,
        'status': 'DITERIMA_TOKO',
        'seller_inspect_deadline': '2026-09-09 10:00:00',
      });

      expect(entry.awaitingInspection, isTrue);
      expect(entry.activeDeadline, entry.sellerInspectDeadline);
    });

    test('decodes evidence photos sent as a JSON string of bare URLs', () {
      // An offer's photos_json holds objects; a return's holds plain strings.
      final entry = ReturnModel.fromJson(payload);

      expect(entry.evidencePhotos, hasLength(2));
      expect(entry.evidencePhotos.first, 'https://contoh.test/bongkar1.jpg');
    });

    test('reads the returned quantity from its DECIMAL string', () {
      expect(ReturnModel.fromJson(payload).qtyReturned, 4);
    });

    test('flags a store pickup, which carries its own 3x24h clock', () {
      final entry = ReturnModel.fromJson(<String, dynamic>{
        ...payload,
        'return_courier_type': 'JEMPUT_TOKO',
        'pickup_deadline': '2026-09-10 09:00:00',
      });

      expect(entry.needsPickup, isTrue);
      expect(entry.pickupDeadline, isNotNull);
    });

    test('has no running clock once the store has answered', () {
      final entry = ReturnModel.fromJson(<String, dynamic>{
        ...payload,
        'status': 'DISETUJUI',
      });

      expect(entry.activeDeadline, isNull);
    });
  });
}
