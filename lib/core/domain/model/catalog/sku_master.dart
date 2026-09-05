import '../../../utils/json_parse.dart';

/// A platform-owned master SKU. Stores attach offers to these; they never
/// create them (API doc 5.4).
class SkuMaster {
  const SkuMaster({
    required this.id,
    required this.name,
    this.categoryId,
    this.brandId,
    this.baseUnit,
    this.weightKg,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.handlingClass,
    this.isQuoteFirst = false,
    this.status,
    this.units = const <SkuUnit>[],
    this.attributes = const <SkuAttribute>[],
  });

  final int id;
  final String name;
  final int? categoryId;
  final int? brandId;
  final String? baseUnit;

  /// Weight and dimensions are **locked** — a store cannot change them
  /// (PRD-08). If it could, it would shrink the weight to cut shipping cost
  /// and the driver would absorb the difference on site. Render read-only.
  final double? weightKg;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;

  final String? handlingClass;
  final bool isQuoteFirst;
  final String? status;
  final List<SkuUnit> units;
  final List<SkuAttribute> attributes;

  factory SkuMaster.fromJson(Map<String, dynamic> json) => SkuMaster(
        id: asInt(json['id']),
        name: asString(json['name']),
        categoryId: asIntOrNull(json['category_id']),
        brandId: asIntOrNull(json['brand_id']),
        baseUnit: asStringOrNull(json['base_unit']),
        weightKg: asDoubleOrNull(json['weight_kg']),
        lengthCm: asDoubleOrNull(json['length_cm']),
        widthCm: asDoubleOrNull(json['width_cm']),
        heightCm: asDoubleOrNull(json['height_cm']),
        handlingClass: asStringOrNull(json['handling_class']),
        isQuoteFirst: asBool(json['is_quote_first']),
        status: asStringOrNull(json['status']),
        units: asModelList(json['units'], SkuUnit.fromJson),
        attributes: asModelList(json['attributes'], SkuAttribute.fromJson),
      );

  String get dimensionsLabel {
    if (lengthCm == null || widthCm == null || heightCm == null) return '-';
    return '${_trim(lengthCm!)} × ${_trim(widthCm!)} × ${_trim(heightCm!)} cm';
  }

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.round().toString() : '$value';
}

/// Order items always report `unit_name_snapshot: "unit"` (API doc 8), so the
/// real unit name — sak, dus, batang — has to come from here.
class SkuUnit {
  const SkuUnit({
    required this.id,
    required this.name,
    this.conversionToBase,
    this.isBase = false,
  });

  final int id;
  final String name;
  final double? conversionToBase;
  final bool isBase;

  factory SkuUnit.fromJson(Map<String, dynamic> json) => SkuUnit(
        id: asInt(json['id']),
        name: asString(json['name'] ?? json['unit_name']),
        conversionToBase: asDoubleOrNull(json['conversion_to_base']),
        isBase: asBool(json['is_base']),
      );
}

class SkuAttribute {
  const SkuAttribute({required this.name, required this.value});

  final String name;
  final String value;

  factory SkuAttribute.fromJson(Map<String, dynamic> json) => SkuAttribute(
        name: asString(json['name'] ?? json['attribute_name']),
        value: asString(json['value'] ?? json['attribute_value']),
      );
}
