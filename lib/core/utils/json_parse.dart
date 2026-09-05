/// Tolerant JSON readers.
///
/// The backend hands MySQL column values straight to `json_encode`, so numbers
/// and booleans arrive as strings far more often than not — `"id": "1"`,
/// `"score": "100.00"`, `"is_official_store": "0"` (API doc 1.7). A direct
/// `json['id'] as int` throws on real responses, so every model reads its
/// fields through these helpers instead.
library;

import 'dart:convert';

int? asIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is bool) return value ? 1 : 0;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed) ?? double.tryParse(trimmed)?.round();
  }
  return null;
}

int asInt(dynamic value, {int fallback = 0}) => asIntOrNull(value) ?? fallback;

double? asDoubleOrNull(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is bool) return value ? 1 : 0;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }
  return null;
}

double asDouble(dynamic value, {double fallback = 0}) =>
    asDoubleOrNull(value) ?? fallback;

/// Reads `true`, `"1"`, `1`, `"true"`, `"yes"` as true; everything else false.
bool asBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return fallback;
    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'yes' ||
        normalized == 'y';
  }
  return fallback;
}

/// Returns null for missing values *and* for empty/whitespace strings, so
/// `"legal_name": ""` and `"legal_name": null` are treated the same way.
String? asStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return value.toString();
}

String asString(dynamic value, {String fallback = ''}) =>
    asStringOrNull(value) ?? fallback;

/// Server timestamps are `YYYY-MM-DD HH:MM:SS` with no timezone (API doc 1.7).
/// They are parsed as-is — no UTC conversion — because they are server wall
/// clock and converting would silently shift every deadline shown to the user.
DateTime? asDateTime(dynamic value) {
  final raw = asStringOrNull(value);
  if (raw == null) return null;
  return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
}

Map<String, dynamic> asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
  return const <String, dynamic>{};
}

Map<String, dynamic>? asMapOrNull(dynamic value) {
  if (value is Map) return asMap(value);
  return null;
}

/// Reads a list of objects, skipping anything that is not a map. Used for
/// `units[]`, `attributes[]`, `sub_orders[]` and friends.
List<Map<String, dynamic>> asMapList(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value.whereType<Map>().map(asMap).toList(growable: false);
}

List<T> asModelList<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) =>
    asMapList(value).map(fromJson).toList(growable: false);

/// Some columns hold JSON that the backend hands back **as a string** rather
/// than as a decoded structure — `photos_json` on an offer and
/// `tier_snapshot_json` on an order item both do this. Reading them as a List
/// or Map without decoding silently yields nothing.
dynamic asDecodedJson(dynamic value) {
  if (value is List || value is Map) return value;
  final raw = asStringOrNull(value);
  if (raw == null) return null;
  try {
    return jsonDecode(raw);
  } on FormatException {
    return null;
  }
}

/// [asMapList] for a field that may arrive either decoded or as a JSON string.
List<Map<String, dynamic>> asEncodedMapList(dynamic value) =>
    asMapList(asDecodedJson(value));

/// [asMap] for a field that may arrive either decoded or as a JSON string.
Map<String, dynamic> asEncodedMap(dynamic value) => asMap(asDecodedJson(value));
