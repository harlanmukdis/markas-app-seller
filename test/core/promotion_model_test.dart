import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/promotion/flash_sale.dart';
import 'package:navy_wear/core/domain/model/promotion/flash_sale_product.dart';
import 'package:navy_wear/core/domain/model/promotion/store_voucher.dart';
import 'package:navy_wear/core/utils/format_helper.dart';

/// Payloads captured from the running marketplace API.
void main() {
  group('StoreVoucher.fromJson', () {
    test('reads a voucher the way the server returns one', () {
      // Verbatim from GET /stores/{id}/vouchers.
      final voucher = StoreVoucher.fromJson(<String, dynamic>{
        'id': '1',
        'store_id': '16',
        'code': 'VC-CE6HJT3U',
        'name': 'Diskon Probe 10%',
        'discount_type': 'percentage',
        'discount_value': '10.00',
        'max_discount': '20000.00',
        'min_spend': '50000.00',
        'quota': '100',
        'used_count': '0',
        'max_use_per_user': '1',
        'valid_from': '2026-09-19 00:00:00',
        'valid_until': '2026-10-19 23:59:59',
        'status': 'active',
      });

      expect(voucher.id, 1);
      expect(voucher.code, 'VC-CE6HJT3U');
      expect(voucher.discountValue, 10, reason: 'a percentage, not rupiah');
      expect(voucher.maxDiscount, 20000);
      expect(voucher.minSpend, 50000);
      expect(voucher.remainingQuota, 100);
      expect(voucher.discountSummary, '10%');
    });

    test('a fixed voucher reads its value as rupiah', () {
      final voucher = StoreVoucher.fromJson(<String, dynamic>{
        'id': '2',
        'code': 'PROBE96609',
        'name': 'Kode Sendiri',
        'discount_type': 'fixed',
        'discount_value': '15000.00',
        'quota': '5',
        'used_count': '0',
      });

      expect(voucher.discountSummary, 'Rp 15.000');
    });

    test('an unrecognised discount type comes back as an empty string', () {
      // MySQL is not in strict mode here, so the server accepts
      // `discount_type: "ngawur"` with a 201 and stores '' — observed live.
      // The voucher exists and discounts nothing, so it has to be legible
      // rather than crash a switch.
      final voucher = StoreVoucher.fromJson(<String, dynamic>{
        'id': '3',
        'code': 'VC-EEYA4K6Z',
        'name': 'Tipe Ngawur',
        'discount_type': '',
        'discount_value': '1000.00',
        'quota': '5',
      });

      expect(voucher.discountType, '');
      expect(VoucherDiscountType.label(voucher.discountType),
          'Tidak dikenali');
    });
  });

  group('StoreVoucher.phaseAt', () {
    StoreVoucher voucher({
      String from = '2026-09-01 00:00:00',
      String until = '2026-10-01 23:59:59',
      String quota = '100',
      String used = '0',
      String status = 'active',
    }) =>
        StoreVoucher.fromJson(<String, dynamic>{
          'id': '1',
          'code': 'VC-TEST',
          'name': 'Tes',
          'discount_type': 'fixed',
          'discount_value': '1000.00',
          'quota': quota,
          'used_count': used,
          'valid_from': from,
          'valid_until': until,
          'status': status,
        });

    test('inside the window with quota left, it is running', () {
      expect(
        voucher().phaseAt(DateTime(2026, 9, 19)),
        VoucherPhase.running,
      );
    });

    test('past valid_until it is expired, though status still says active', () {
      // Nothing on the backend ever writes `vouchers.status` — there is no
      // endpoint and no worker — so it reads 'active' forever. Trusting it
      // would show a voucher as live years after it stopped working.
      final expired = voucher();
      expect(expired.status, 'active');
      expect(
        expired.phaseAt(DateTime(2026, 11, 1)),
        VoucherPhase.expired,
      );
    });

    test('before valid_from it is scheduled', () {
      expect(
        voucher().phaseAt(DateTime(2026, 8, 1)),
        VoucherPhase.scheduled,
      );
    });

    test('quota spent is exhausted rather than running', () {
      expect(
        voucher(quota: '5', used: '5').phaseAt(DateTime(2026, 9, 19)),
        VoucherPhase.exhausted,
      );
    });

    test('expiry outranks an exhausted quota', () {
      expect(
        voucher(quota: '5', used: '5').phaseAt(DateTime(2026, 11, 1)),
        VoucherPhase.expired,
      );
    });
  });

  group('FlashSale.phaseAt', () {
    FlashSale sale({
      String start = '2026-09-19 00:00:00',
      String end = '2026-09-30 23:59:59',
      String status = 'active',
    }) =>
        FlashSale.fromJson(<String, dynamic>{
          'id': '1',
          'store_id': '16',
          'name': 'Flash Probe',
          'start_at': start,
          'end_at': end,
          'status': status,
        });

    test('active status inside the window is what buyers actually see', () {
      expect(
        sale().phaseAt(DateTime(2026, 9, 25)),
        FlashSalePhase.running,
      );
    });

    test('an open window that never left `scheduled` is stalled', () {
      // The one that matters. `status` is computed once, at creation, and moved
      // afterwards only by a five-minute cron worker. A sale created for later
      // is born `scheduled`, and where that worker is not running it stays
      // there through its whole window — while the buyer-facing query demands
      // BOTH `status = 'active'` AND the window. So the sale looks scheduled,
      // its time has come, and it sells nothing.
      expect(
        sale(status: 'scheduled').phaseAt(DateTime(2026, 9, 25)),
        FlashSalePhase.stalled,
      );
    });

    test('past its end it is over, whatever the status says', () {
      expect(
        sale().phaseAt(DateTime(2026, 10, 5)),
        FlashSalePhase.ended,
      );
    });

    test('before its start it is scheduled', () {
      expect(
        sale(status: 'scheduled').phaseAt(DateTime(2026, 9, 1)),
        FlashSalePhase.scheduled,
      );
    });

    test('a backwards window is flagged rather than accepted quietly', () {
      // The server takes `end_at` before `start_at` with a 201 and stores it —
      // observed live. The sale can never run.
      final reversed = sale(
        start: '2026-12-05 00:00:00',
        end: '2026-12-01 00:00:00',
        status: 'scheduled',
      );

      expect(reversed.hasImpossibleWindow, isTrue);
      expect(sale().hasImpossibleWindow, isFalse);
    });
  });

  group('FlashSaleProduct', () {
    FlashSaleProduct row({
      String flashPrice = '75000.00',
      String original = '100000.00',
      String quota = '10',
      String sold = '0',
    }) =>
        FlashSaleProduct.fromJson(<String, dynamic>{
          'id': '1',
          'flash_sale_id': '1',
          'product_variant_id': '26',
          'flash_price': flashPrice,
          'stock_quota': quota,
          'sold_count': sold,
          'max_qty_per_user': '2',
          'sku': 'SKU-20-CCBE86',
          'original_price': original,
          'product_id': '20',
          'product_name': 'Produk Promo Probe',
          'image_url': null,
        });

    test('reads the joined row a sale returns', () {
      final product = row();

      expect(product.flashPrice, 75000);
      expect(product.originalPrice, 100000);
      expect(product.productId, 20);
      expect(product.discountPercent, 25);
      expect(product.remainingQuota, 10);
      expect(product.isSoldOut, isFalse);
    });

    test('a flash price at or above the normal one is not a discount', () {
      // The server does not compare the two, so this row is accepted and would
      // otherwise render as a saving.
      final product = row(flashPrice: '120000.00');

      expect(product.isDiscounted, isFalse);
      expect(product.discountPercent, 0);
    });

    test('quota spent reads as sold out', () {
      final product = row(quota: '10', sold: '10');

      expect(product.remainingQuota, 0);
      expect(product.isSoldOut, isTrue);
    });
  });

  group('formatApiDateTime', () {
    test('sends plain wall clock, which is what the columns hold', () {
      // No `T` and no offset: the backend compares these against MySQL NOW(),
      // so an ISO-8601 string with a zone would mean a different moment.
      expect(
        formatApiDateTime(DateTime(2026, 9, 19, 8, 5, 3)),
        '2026-09-19 08:05:03',
      );
    });
  });
}
