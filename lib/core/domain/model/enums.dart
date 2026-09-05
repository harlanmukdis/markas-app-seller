/// Server enums, kept as string constants rather than Dart enums.
///
/// A Dart enum would throw on any value the backend adds later; a constant
/// compares cleanly and lets unknown values fall through to a neutral label.
/// Values are from API doc 6.
abstract class SellerStatus {
  static const String draft = 'DRAFT';
  static const String pendingKyc = 'PENDING_KYC';
  static const String kycRejected = 'KYC_REJECTED';
  static const String verified = 'VERIFIED';
  static const String suspended = 'SUSPENDED';

  static String label(String? status) => switch (status) {
        draft => 'Draft',
        pendingKyc => 'Menunggu verifikasi KYC',
        kycRejected => 'KYC ditolak',
        verified => 'Terverifikasi',
        suspended => 'Dibekukan',
        _ => status ?? '-',
      };
}

abstract class SellerType {
  static const String toko = 'TOKO';
  static const String distributor = 'DISTRIBUTOR';

  /// Purely a display distinction — onboarding, catalogue, orders and payouts
  /// behave identically for both (API doc 5.1).
  static const List<String> all = <String>[toko, distributor];

  static String label(String? type) => switch (type) {
        toko => 'Toko',
        distributor => 'Distributor',
        _ => type ?? '-',
      };
}

/// Document types accepted by `kyc_upload`.
abstract class KycDocType {
  static const String ktp = 'KTP';
  static const String npwp = 'NPWP';
  static const String nib = 'NIB';
  static const String siup = 'SIUP';
  static const String bukuRekening = 'BUKU_REKENING';
  static const String skb = 'SKB';
  static const String suratPernyataanBermeterai = 'SURAT_PERNYATAAN_BERMETERAI';
  static const String perjanjianKerjasama = 'PERJANJIAN_KERJASAMA';

  static const List<String> all = <String>[
    ktp,
    npwp,
    nib,
    siup,
    bukuRekening,
    skb,
    suratPernyataanBermeterai,
    perjanjianKerjasama,
  ];

  /// The set a store normally has to clear gate 1: KTP, NPWP, NIB *or* SIUP,
  /// and BUKU_REKENING (API doc 5.2).
  static const List<String> requiredForGate = <String>[
    ktp,
    npwp,
    nib,
    bukuRekening,
  ];

  static String label(String? type) => switch (type) {
        ktp => 'KTP',
        npwp => 'NPWP',
        nib => 'NIB',
        siup => 'SIUP',
        bukuRekening => 'Buku rekening',
        skb => 'SKB',
        suratPernyataanBermeterai => 'Surat pernyataan bermeterai',
        perjanjianKerjasama => 'Perjanjian kerja sama',
        _ => type ?? '-',
      };
}

abstract class DocStatus {
  static const String pending = 'PENDING';
  static const String approved = 'APPROVED';
  static const String rejected = 'REJECTED';
  static const String verified = 'VERIFIED';

  static String label(String? status) => switch (status) {
        pending => 'Menunggu',
        approved => 'Disetujui',
        verified => 'Terverifikasi',
        rejected => 'Ditolak',
        _ => status ?? '-',
      };
}

abstract class FleetTypeCode {
  static const String motor = 'MOTOR';
  static const String pickup = 'PICKUP';
  static const String cde = 'CDE';
  static const String cdd = 'CDD';
  static const String fuso = 'FUSO';
  static const String tronton = 'TRONTON';

  /// Fallback order for the picker when `GET /fleet-types` cannot be reached.
  static const List<String> all = <String>[
    motor,
    pickup,
    cde,
    cdd,
    fuso,
    tronton,
  ];
}

abstract class ShippingRateMode {
  /// Flat per zone.
  static const String simple = 'SIMPLE';
  static const String detail = 'DETAIL';

  static const List<String> all = <String>[simple, detail];

  static String label(String? mode) => switch (mode) {
        simple => 'Sederhana (flat per zona)',
        detail => 'Detail',
        _ => mode ?? '-',
      };
}

abstract class UserRole {
  static const String seller = 'SEL';
}
