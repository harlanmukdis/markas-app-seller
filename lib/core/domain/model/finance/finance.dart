import '../../../utils/json_parse.dart';

/// `GET /finance/balance`. Both figures are computed from the ledger, not read
/// from a mutable balance column (FIN-02/FIN-11).
class SellerBalance {
  const SellerBalance({
    required this.sellerId,
    this.held = 0,
    this.available = 0,
  });

  final int sellerId;

  /// Completed shipments still inside their hold window (T+3, T+7 for fragile,
  /// longer for a store on trial), or frozen by an open dispute.
  final int held;

  /// Withdrawable now.
  final int available;

  factory SellerBalance.fromJson(Map<String, dynamic> json) => SellerBalance(
        sellerId: asInt(json['seller_id']),
        held: asInt(json['held']),
        available: asInt(json['available']),
      );

  int get total => held + available;
}

/// One row of the balance ledger. The balance is allowed to go **negative**
/// when a refund lands after the money was released — that is recorded as the
/// platform's receivable from the store (RET-13).
class LedgerEntry {
  const LedgerEntry({
    required this.id,
    this.entryType,
    this.amount = 0,
    this.balanceBucket,
    this.shipmentId,
    this.note,
    this.createdAt,
  });

  final int id;
  final String? entryType;
  final int amount;
  final String? balanceBucket;
  final int? shipmentId;
  final String? note;
  final DateTime? createdAt;

  factory LedgerEntry.fromJson(Map<String, dynamic> json) => LedgerEntry(
        id: asInt(json['id']),
        entryType: asStringOrNull(json['entry_type']),
        amount: asInt(json['amount']),
        balanceBucket: asStringOrNull(json['balance_bucket']),
        shipmentId: asIntOrNull(json['shipment_id']),
        note: asStringOrNull(json['note']),
        createdAt: asDateTime(json['created_at']),
      );

  bool get isCredit => amount >= 0;
}

/// The payout breakdown for one shipment.
///
/// Every component is shown as sent, never recombined: transparency about
/// deductions is one of the three things the spec says decides whether a store
/// stays on the platform.
///
/// ```
/// netto = bruto − komisi − pph22 − voucher_seller_burden + ongkir
/// ```
///
/// Shipping is 100% the store's — the platform takes no margin on it (FIN-04).
class Payout {
  const Payout({
    required this.id,
    this.shipmentId,
    this.bruto = 0,
    this.komisi = 0,
    this.pph22 = 0,
    this.voucherSellerBurden = 0,
    this.ongkir = 0,
    this.netto = 0,
    this.status,
    this.holdReleaseAt,
    this.frozenAt,
    this.frozenReason,
    this.releasedAt,
  });

  final int id;
  final int? shipmentId;
  final int bruto;
  final int komisi;
  final int pph22;
  final int voucherSellerBurden;
  final int ongkir;
  final int netto;
  final String? status;
  final DateTime? holdReleaseAt;

  /// A dispute freezes this one shipment only; others keep paying out
  /// (PAY-13). Funds may not be frozen beyond 30 days (DSP-08).
  final DateTime? frozenAt;
  final String? frozenReason;

  final DateTime? releasedAt;

  factory Payout.fromJson(Map<String, dynamic> json) => Payout(
        id: asInt(json['id']),
        shipmentId: asIntOrNull(json['shipment_id']),
        bruto: asInt(json['bruto']),
        komisi: asInt(json['komisi']),
        pph22: asInt(json['pph22']),
        voucherSellerBurden: asInt(json['voucher_seller_burden']),
        ongkir: asInt(json['ongkir']),
        netto: asInt(json['netto']),
        status: asStringOrNull(json['status']),
        holdReleaseAt: asDateTime(json['hold_release_at']),
        frozenAt: asDateTime(json['frozen_at']),
        frozenReason: asStringOrNull(json['frozen_reason']),
        releasedAt: asDateTime(json['released_at']),
      );

  bool get isFrozen => frozenAt != null;

  int get totalDeductions => komisi + pph22 + voucherSellerBurden;
}

/// `POST /finance/withdraw`. Needs Admin Finance approval, so this is
/// "submitted", never "paid".
class WithdrawalRequest {
  const WithdrawalRequest({required this.requestId, this.status});

  final int requestId;
  final String? status;

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) =>
      WithdrawalRequest(
        requestId: asInt(json['request_id'] ?? json['id']),
        status: asStringOrNull(json['status']),
      );
}

/// `GET /config/parameters?group=` — so the app does not hardcode thresholds
/// like the withdrawal minimum or the hold length.
class ConfigParameter {
  const ConfigParameter({
    required this.paramKey,
    required this.paramValue,
    this.paramGroup,
    this.valueType,
    this.description,
  });

  final String paramKey;
  final String paramValue;
  final String? paramGroup;
  final String? valueType;
  final String? description;

  factory ConfigParameter.fromJson(Map<String, dynamic> json) =>
      ConfigParameter(
        paramKey: asString(json['param_key']),
        paramValue: asString(json['param_value']),
        paramGroup: asStringOrNull(json['param_group']),
        valueType: asStringOrNull(json['value_type']),
        description: asStringOrNull(json['description']),
      );

  int? get asInteger => asIntOrNull(paramValue);

  double? get asNumber => asDoubleOrNull(paramValue);
}

abstract class ConfigGroup {
  static const String ambang = 'AMBANG';
  static const String pencairan = 'PENCAIRAN';
  static const String tokoBaru = 'TOKO_BARU';
  static const String kontrak = 'KONTRAK';
  static const String pajak = 'PAJAK';
  static const String jasa = 'JASA';
}
