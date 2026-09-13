import '../../../utils/json_parse.dart';

/// `GET /stores/{id}/settings`.
///
/// Vacation mode is the feature the previous backend never had: a way to stop
/// taking orders without deleting the catalogue, which is what a store
/// actually needs when the owner travels.
class StoreSettings {
  const StoreSettings({
    required this.storeId,
    this.autoAcceptOrder = false,
    this.vacationMode = false,
    this.vacationMessage,
    this.defaultCurrency = 'IDR',
    this.operationalHours,
  });

  final int storeId;

  /// When set, paid orders skip the manual accept step.
  final bool autoAcceptOrder;

  final bool vacationMode;
  final String? vacationMessage;
  final String defaultCurrency;

  /// Free-form JSON on the server; kept raw because no screen reads it yet and
  /// inventing a shape for it would be guessing.
  final Map<String, dynamic>? operationalHours;

  factory StoreSettings.fromJson(Map<String, dynamic> json) => StoreSettings(
        storeId: asInt(json['store_id']),
        autoAcceptOrder: asBool(json['auto_accept_order']),
        vacationMode: asBool(json['vacation_mode']),
        vacationMessage: asStringOrNull(json['vacation_message']),
        defaultCurrency:
            asString(json['default_currency'], fallback: 'IDR'),
        operationalHours: asMapOrNull(asDecodedJson(json['operational_hours'])),
      );
}
