import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/rfq/rfq.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

class RfqService extends BaseService {
  const RfqService(super.dio);

  /// Only RFQs this store was invited into.
  Future<List<Rfq>> getRfqs() async {
    final envelope = await getRequest(ApiEndpoints.rfq);
    return envelope.listAt('rfq').map(Rfq.fromJson).toList(growable: false);
  }

  Future<Rfq> getRfq(int rfqId) async {
    final envelope = await getRequest(ApiEndpoints.rfqDetail(rfqId));
    return Rfq.fromJson(envelope.map);
  }

  /// With a `SEL` token, only this store's own quotes.
  Future<List<RfqOffer>> getRfqOffers(int rfqId) async {
    final envelope = await getRequest(ApiEndpoints.rfqOffers(rfqId));
    return envelope
        .listAt('offers')
        .map(RfqOffer.fromJson)
        .toList(growable: false);
  }

  /// Submitting a quote, or revising one.
  ///
  /// A revision is a **new version**, not an overwrite: pass the previous
  /// quote as [parentOfferId] and it becomes SUPERSEDED while this one gets
  /// `version_no + 1`, keeping the negotiation history intact (RFQ-06).
  ///
  /// [termsSkuId] should effectively always be set — it is what the system
  /// uses to compute the median reference price for contract price
  /// adjustments; without it that mechanism cannot run for the contract.
  Future<RfqOffer> submitOffer(
    int rfqId, {
    required int price,
    required double qty,
    String? validUntil,
    int? termsSkuId,
    String? termsNote,
    int? parentOfferId,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.rfqOffers(rfqId),
      body: <String, dynamic>{
        'price': price,
        'qty': qty,
        'valid_until': validUntil,
        'terms_json': <String, dynamic>{
          if (termsSkuId != null) 'sku_id': termsSkuId,
          if (termsNote != null) 'catatan': termsNote,
        },
        'parent_offer_id': parentOfferId,
      },
    );
    final body = envelope.map;
    return RfqOffer(
      id: asInt(body['offer_id'] ?? body['id']),
      rfqId: rfqId,
      price: price,
      qty: qty,
      versionNo: asInt(body['version_no'], fallback: 1),
      validUntil: asDateTime(body['valid_until']),
      parentOfferId: parentOfferId,
      termsSkuId: termsSkuId,
      termsNote: termsNote,
    );
  }

  /// Mid-contract price adjustment. Valid only when the reference price moved
  /// more than ±5%, only for batches not yet invoiced, and once per batch.
  ///
  /// Symmetric and risky: the buyer may ask for a reduction too, and **buyer
  /// silence cancels the remaining contract rather than approving it**
  /// (RFQ-15/RFQ-17). Warn before submitting.
  Future<void> requestAdjustment(int contractId) async {
    await postRequest(ApiEndpoints.rfqRequestAdjustment(contractId));
  }

  Future<List<RfqBatch>> getBatches(int contractId) async {
    final envelope = await getRequest(ApiEndpoints.rfqBatches(contractId));
    return envelope
        .listAt('batches')
        .map(RfqBatch.fromJson)
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getCancellationTerms(int contractId) async {
    final envelope =
        await getRequest(ApiEndpoints.rfqCancellationTerms(contractId));
    return envelope.map;
  }
}
