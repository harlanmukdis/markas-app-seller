import '../../../utils/json_parse.dart';

/// A contractor's request for quotes. The platform's primary customer path.
///
/// A store is invited automatically when it has an ACTIVE offer in the
/// requested category — and only PKP stores are invited when the buyer flagged
/// that it needs a tax invoice (RFQ-03).
class Rfq {
  const Rfq({
    required this.id,
    this.rfqNo,
    this.buyerId,
    this.title,
    this.categoryId,
    this.status,
    this.maxFleetTypeCode,
    this.deadlineTokoJawab,
    this.needTaxInvoice = false,
    this.deliveryAddress,
    this.createdAt,
    this.items = const <RfqItem>[],
  });

  final int id;
  final String? rfqNo;
  final int? buyerId;
  final String? title;
  final int? categoryId;
  final String? status;

  /// The largest vehicle that can physically reach the site. Quoting with a
  /// truck that does not fit is the most common cause of failed delivery in
  /// this category.
  final String? maxFleetTypeCode;

  /// 2×24 working hours. Miss it and the store drops off the bidder list
  /// (TO-17).
  final DateTime? deadlineTokoJawab;

  final bool needTaxInvoice;
  final String? deliveryAddress;
  final DateTime? createdAt;
  final List<RfqItem> items;

  factory Rfq.fromJson(Map<String, dynamic> json) => Rfq(
        id: asInt(json['id']),
        rfqNo: asStringOrNull(json['rfq_no']),
        buyerId: asIntOrNull(json['buyer_id']),
        title: asStringOrNull(json['title']),
        categoryId: asIntOrNull(json['category_id']),
        status: asStringOrNull(json['status']),
        maxFleetTypeCode: asStringOrNull(json['max_fleet_type_code']),
        deadlineTokoJawab: asDateTime(json['deadline_toko_jawab']),
        needTaxInvoice: asBool(json['need_tax_invoice']),
        deliveryAddress: asStringOrNull(json['delivery_address']),
        createdAt: asDateTime(json['created_at']),
        items: asModelList(json['items'], RfqItem.fromJson),
      );
}

class RfqItem {
  const RfqItem({
    required this.id,
    this.skuId,
    this.name,
    this.qty = 0,
    this.unitName,
    this.note,
  });

  final int id;
  final int? skuId;
  final String? name;
  final double qty;
  final String? unitName;
  final String? note;

  factory RfqItem.fromJson(Map<String, dynamic> json) => RfqItem(
        id: asInt(json['id']),
        skuId: asIntOrNull(json['sku_id']),
        name: asStringOrNull(json['name'] ?? json['item_name']),
        qty: asDouble(json['qty']),
        unitName: asStringOrNull(json['unit_name']),
        note: asStringOrNull(json['note']),
      );
}

/// A quote. Revising means submitting a **new version** with `parent_offer_id`
/// set — the old one becomes SUPERSEDED and history stays intact (RFQ-06).
class RfqOffer {
  const RfqOffer({
    required this.id,
    this.rfqId,
    this.sellerId,
    this.price = 0,
    this.qty = 0,
    this.versionNo = 1,
    this.status,
    this.validUntil,
    this.parentOfferId,
    this.termsSkuId,
    this.termsNote,
    this.createdAt,
  });

  final int id;
  final int? rfqId;
  final int? sellerId;
  final int price;
  final double qty;
  final int versionNo;
  final String? status;
  final DateTime? validUntil;
  final int? parentOfferId;

  /// `terms_json.sku_id`. Worth always sending: it is what the system uses to
  /// compute the median reference price for mid-contract price adjustments.
  /// Without it, automatic adjustment cannot run for that contract.
  final int? termsSkuId;

  final String? termsNote;
  final DateTime? createdAt;

  factory RfqOffer.fromJson(Map<String, dynamic> json) {
    final terms = asEncodedMap(json['terms_json']);
    return RfqOffer(
      id: asInt(json['id'] ?? json['offer_id']),
      rfqId: asIntOrNull(json['rfq_id']),
      sellerId: asIntOrNull(json['seller_id']),
      price: asInt(json['price']),
      qty: asDouble(json['qty']),
      versionNo: asInt(json['version_no'], fallback: 1),
      status: asStringOrNull(json['status']),
      validUntil: asDateTime(json['valid_until']),
      parentOfferId: asIntOrNull(json['parent_offer_id']),
      termsSkuId: asIntOrNull(terms['sku_id']),
      termsNote: asStringOrNull(terms['catatan'] ?? terms['note']),
      createdAt: asDateTime(json['created_at']),
    );
  }

  /// Only a SUBMITTED quote can be revised.
  bool get canRevise => status == RfqOfferStatus.submitted;

  int get lineTotal => (price * qty).round();
}

abstract class RfqOfferStatus {
  static const String submitted = 'SUBMITTED';
  static const String superseded = 'SUPERSEDED';
  static const String accepted = 'ACCEPTED';
  static const String rejected = 'REJECTED';
  static const String expired = 'EXPIRED';

  static String label(String? status) => switch (status) {
        submitted => 'Diajukan',
        superseded => 'Digantikan versi baru',
        accepted => 'Diterima',
        rejected => 'Ditolak',
        expired => 'Kedaluwarsa',
        _ => status ?? '-',
      };
}

/// One delivery batch of an awarded contract.
class RfqBatch {
  const RfqBatch({
    required this.id,
    this.contractId,
    this.batchNo,
    this.qty = 0,
    this.status,
    this.scheduledDate,
    this.invoicedAt,
  });

  final int id;
  final int? contractId;
  final int? batchNo;
  final double qty;
  final String? status;
  final DateTime? scheduledDate;
  final DateTime? invoicedAt;

  factory RfqBatch.fromJson(Map<String, dynamic> json) => RfqBatch(
        id: asInt(json['id']),
        contractId: asIntOrNull(json['contract_id']),
        batchNo: asIntOrNull(json['batch_no']),
        qty: asDouble(json['qty']),
        status: asStringOrNull(json['status']),
        scheduledDate: asDateTime(json['scheduled_date']),
        invoicedAt: asDateTime(json['invoiced_at']),
      );

  bool get isInvoiced => invoicedAt != null;
}
