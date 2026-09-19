import '../../../utils/json_parse.dart';

/// One row of `GET /stores/{id}/flash-sales`.
///
/// Like vouchers, this is create-and-list only: no `PATCH`, no `DELETE`. A
/// flash sale cannot be renamed, rescheduled or called off once it exists —
/// the `cancelled` value in the status enum has no code path that writes it.
class FlashSale {
  const FlashSale({
    required this.id,
    required this.name,
    this.storeId,
    this.startAt,
    this.endAt,
    this.status = FlashSaleStatus.scheduled,
  });

  final int id;
  final String name;

  /// Null on a platform-wide sale.
  final int? storeId;

  final DateTime? startAt;
  final DateTime? endAt;

  /// What the server last computed — **not** necessarily what is true now.
  ///
  /// It is set once by SQL `NOW()` at creation and moved afterwards only by
  /// `flash_sale_status_worker.php` on a five-minute cron. Where that cron is
  /// not installed the value simply never changes again, which is why
  /// [phaseAt] treats it as one input rather than the answer.
  final String status;

  factory FlashSale.fromJson(Map<String, dynamic> json) => FlashSale(
        id: asInt(json['id']),
        name: asString(json['name']),
        storeId: asIntOrNull(json['store_id']),
        startAt: asDateTime(json['start_at']),
        endAt: asDateTime(json['end_at']),
        status: asString(json['status'], fallback: FlashSaleStatus.scheduled),
      );

  /// Whether the window is open, ignoring what [status] claims.
  bool windowCoversNow(DateTime now) {
    if (startAt != null && now.isBefore(startAt!)) return false;
    if (endAt != null && now.isAfter(endAt!)) return false;
    return true;
  }

  /// What buyers actually get.
  ///
  /// The discount reaches `GET /products/{id}` only when **both** conditions
  /// hold: `flash_sales.status = 'active'` *and* the window covers `NOW()`.
  /// That pairing is what makes [FlashSalePhase.stalled] possible — a sale
  /// whose window is open but whose status was never advanced past
  /// `scheduled`, so it silently sells nothing.
  ///
  /// Timestamps are server wall-clock with no zone and are compared against
  /// local `now`; both are Asia/Jakarta in this deployment.
  FlashSalePhase phaseAt(DateTime now) {
    if (status == FlashSaleStatus.cancelled) return FlashSalePhase.cancelled;
    if (endAt != null && now.isAfter(endAt!)) return FlashSalePhase.ended;
    if (startAt != null && now.isBefore(startAt!)) {
      return FlashSalePhase.scheduled;
    }
    if (!windowCoversNow(now)) return FlashSalePhase.ended;
    return status == FlashSaleStatus.active
        ? FlashSalePhase.running
        : FlashSalePhase.stalled;
  }

  FlashSalePhase get phase => phaseAt(DateTime.now());

  /// A window that ends before it starts. The server accepts one with a `201`
  /// and stores it, leaving a sale that can never run.
  bool get hasImpossibleWindow =>
      startAt != null && endAt != null && endAt!.isBefore(startAt!);
}

/// Where a sale is in its life, worked out from the window **and** the status
/// together, because either one alone is misleading.
enum FlashSalePhase {
  /// Live: status is `active` and the window is open.
  running,

  /// The window is open but the status was never advanced, so buyers see
  /// nothing. Recoverable only by the status worker — there is no endpoint
  /// that can fix it from here.
  stalled,

  scheduled,
  ended,
  cancelled,
}

extension FlashSalePhaseLabel on FlashSalePhase {
  String get label => switch (this) {
        FlashSalePhase.running => 'Berjalan',
        FlashSalePhase.stalled => 'Tidak jalan',
        FlashSalePhase.scheduled => 'Terjadwal',
        FlashSalePhase.ended => 'Berakhir',
        FlashSalePhase.cancelled => 'Dibatalkan',
      };
}

abstract class FlashSaleStatus {
  static const String scheduled = 'scheduled';
  static const String active = 'active';
  static const String ended = 'ended';

  /// In the schema, written by nothing.
  static const String cancelled = 'cancelled';
}
