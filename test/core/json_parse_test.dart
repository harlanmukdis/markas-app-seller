import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/utils/json_parse.dart';

/// The backend hands MySQL column values straight to `json_encode`, so these
/// helpers are what stands between a real response and a cast error. The cases
/// below are the shapes the API doc actually documents.
void main() {
  group('asInt', () {
    test('reads the string integers MySQL returns', () {
      expect(asInt('1'), 1);
      expect(asInt('  42 '), 42);
      expect(asInt(7), 7);
    });

    test('rounds a decimal string like "100.00"', () {
      expect(asInt('100.00'), 100);
      expect(asInt('100.6'), 101);
    });

    test('falls back rather than throwing on junk', () {
      expect(asInt(null), 0);
      expect(asInt(''), 0);
      expect(asInt('abc', fallback: -1), -1);
      expect(asIntOrNull('abc'), isNull);
    });
  });

  group('asDouble', () {
    test('parses the score field as sent', () {
      expect(asDouble('100.00'), 100.0);
      expect(asDouble(98), 98.0);
    });

    test('returns null for unparseable input', () {
      expect(asDoubleOrNull('n/a'), isNull);
      expect(asDoubleOrNull(null), isNull);
    });
  });

  group('asBool', () {
    test('reads the "0"/"1" flags MySQL returns', () {
      expect(asBool('0'), isFalse);
      expect(asBool('1'), isTrue);
      expect(asBool(0), isFalse);
      expect(asBool(1), isTrue);
    });

    test('reads real booleans and word forms', () {
      expect(asBool(true), isTrue);
      expect(asBool('true'), isTrue);
      expect(asBool('yes'), isTrue);
      expect(asBool('false'), isFalse);
    });

    test('uses the fallback for null and empty', () {
      expect(asBool(null), isFalse);
      expect(asBool(null, fallback: true), isTrue);
      expect(asBool('', fallback: true), isTrue);
    });
  });

  group('asStringOrNull', () {
    test('treats an empty or whitespace string as absent', () {
      expect(asStringOrNull(''), isNull);
      expect(asStringOrNull('   '), isNull);
      expect(asStringOrNull(null), isNull);
    });

    test('trims and stringifies', () {
      expect(asStringOrNull('  BCA '), 'BCA');
      expect(asStringOrNull(12), '12');
    });
  });

  group('asDateTime', () {
    test('parses the server format, which has a space and no timezone', () {
      final parsed = asDateTime('2026-09-05 09:39:13');

      expect(parsed, isNotNull);
      expect(parsed!.year, 2026);
      expect(parsed.month, 9);
      expect(parsed.day, 5);
      expect(parsed.hour, 9);
      expect(parsed.minute, 39);
    });

    test('does not shift the value into UTC', () {
      // These are server wall-clock timestamps. Converting them would move
      // every displayed deadline by the viewer's offset.
      expect(asDateTime('2026-09-05 09:39:13')!.isUtc, isFalse);
    });

    test('returns null for null and for garbage', () {
      expect(asDateTime(null), isNull);
      expect(asDateTime('not a date'), isNull);
    });
  });

  group('asMapList', () {
    test('returns an empty list when the field is not a list', () {
      expect(asMapList(null), isEmpty);
      expect(asMapList('nope'), isEmpty);
    });

    test('skips entries that are not objects', () {
      final result = asMapList(<dynamic>[
        <String, dynamic>{'id': '1'},
        'junk',
        <String, dynamic>{'id': '2'},
      ]);

      expect(result, hasLength(2));
      expect(asInt(result.last['id']), 2);
    });
  });
}
