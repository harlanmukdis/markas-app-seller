import '../../../utils/json_parse.dart';

/// The four activation gates (API doc 3). A store cannot sell until all four
/// pass; `sellers.status` flips to `VERIFIED` automatically as soon as the last
/// one clears, whatever order they clear in.
///
/// This object is the *only* source for the onboarding checklist. Deriving the
/// same booleans from document statuses on the client would drift from what the
/// backend actually enforces.
class ActivationGates {
  const ActivationGates({
    this.kycApproved = false,
    this.bankVerified = false,
    this.hasShippingRate = false,
    this.agreementSigned = false,
    this.allPassed = false,
  });

  final bool kycApproved;
  final bool bankVerified;
  final bool hasShippingRate;
  final bool agreementSigned;
  final bool allPassed;

  factory ActivationGates.fromJson(Map<String, dynamic> json) =>
      ActivationGates(
        kycApproved: asBool(json['kyc_approved']),
        bankVerified: asBool(json['bank_verified']),
        hasShippingRate: asBool(json['has_shipping_rate']),
        agreementSigned: asBool(json['agreement_signed']),
        allPassed: asBool(json['all_passed']),
      );

  bool isPassed(SellerGate gate) => switch (gate) {
        SellerGate.kyc => kycApproved,
        SellerGate.bank => bankVerified,
        SellerGate.shippingRate => hasShippingRate,
        SellerGate.agreement => agreementSigned,
      };

  int get passedCount => SellerGate.values.where(isPassed).length;

  List<SellerGate> get pending =>
      SellerGate.values.where((gate) => !isPassed(gate)).toList();
}

/// Presented in this order deliberately.
///
/// Gate 2 has a hidden dependency (API doc 3): `bank_verified_at` is only set
/// if KYC was approved *first*. If finance verifies the account before KYC
/// clears, the column stays empty and the gate silently stays shut. Showing the
/// gates in order keeps a store from walking into that.
enum SellerGate {
  kyc,
  bank,
  shippingRate,
  agreement;

  String get title => switch (this) {
        kyc => 'Dokumen KYC disetujui',
        bank => 'Rekening pencairan tervalidasi',
        shippingRate => 'Tarif ongkir minimal 1 zona',
        agreement => 'Perjanjian kerja sama ditandatangani',
      };

  /// Whether the store can finish this itself, or has to wait on an admin.
  bool get isSelfServe => switch (this) {
        kyc => false,
        bank => false,
        shippingRate => true,
        agreement => true,
      };

  String get waitingOn => switch (this) {
        kyc => 'Menunggu persetujuan Admin Ops/Katalog',
        bank => 'Menunggu verifikasi Admin Finance',
        shippingRate => 'Bisa diselesaikan sekarang',
        agreement => 'Bisa diselesaikan sekarang',
      };
}
