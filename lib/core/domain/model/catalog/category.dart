import '../../../utils/json_parse.dart';

/// `GET /categories`.
///
/// [jalur] is the field that branches the whole catalogue flow: `MASTER`
/// categories require attaching an offer to an existing master SKU, `BEBAS`
/// lets the store define the product itself (API doc 5.4).
class Category {
  const Category({
    required this.id,
    required this.name,
    this.parentId,
    this.slug,
    this.level,
    this.jalur,
    this.isRisky = false,
  });

  final int id;
  final String name;
  final int? parentId;
  final String? slug;
  final String? level;
  final String? jalur;
  final bool isRisky;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: asInt(json['id']),
        name: asString(json['name']),
        parentId: asIntOrNull(json['parent_id']),
        slug: asStringOrNull(json['slug']),
        level: asStringOrNull(json['level']),
        jalur: asStringOrNull(json['jalur']),
        isRisky: asBool(json['is_risky']),
      );

  bool get requiresMasterSku => jalur == CategoryJalur.master;

  bool get allowsFreeform => jalur == CategoryJalur.bebas;
}

abstract class CategoryJalur {
  static const String master = 'MASTER';
  static const String bebas = 'BEBAS';

  static String label(String? jalur) => switch (jalur) {
        master => 'Wajib SKU master',
        bebas => 'Boleh produk sendiri',
        _ => jalur ?? '-',
      };
}
