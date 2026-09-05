import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/shipping/fleet_type.dart';
import 'package:navy_wear/core/domain/model/shipping/shipping_rate.dart';
import 'package:navy_wear/core/domain/model/shipping/zone.dart';
import 'package:navy_wear/features/seller_onboarding/presentation/cubits/shipping_rate_cubit/shipping_rate_cubit.dart';

/// Payloads below are copied from live responses of the running backend, not
/// from the documentation — the two disagree about fleet capacity.
void main() {
  group('FleetType.fromJson', () {
    test('reads capacity_kg_desc, which is prose and not a number', () {
      // The API doc implies a numeric capacity; the server actually sends
      // "± 5 ton". Parsing it as a double silently yielded null.
      final fleetType = FleetType.fromJson(<String, dynamic>{
        'code': 'CDD',
        'name': 'Colt Diesel Double',
        'capacity_kg_desc': '± 5 ton',
      });

      expect(fleetType.code, 'CDD');
      expect(fleetType.capacityDescription, '± 5 ton');
      expect(fleetType.displayLabel, 'Colt Diesel Double (± 5 ton)');
    });

    test('drops the capacity from the label when absent', () {
      final fleetType = FleetType.fromJson(<String, dynamic>{
        'code': 'MOTOR',
        'name': 'Sepeda Motor',
      });

      expect(fleetType.displayLabel, 'Sepeda Motor');
    });
  });

  group('Zone.fromJson', () {
    test('reads the string ids the server sends', () {
      final zone = Zone.fromJson(<String, dynamic>{
        'id': '109',
        'parent_id': '22',
        'level': 'ZONE',
        'name': 'Bekasi Kabupaten',
        'code': 'ZONE-BEKASI-2',
        'created_at': '2026-09-05 14:08:20',
      });

      expect(zone.id, 109);
      expect(zone.parentId, 22);
      expect(zone.isLeafZone, isTrue);
    });

    test('treats PROVINCE and CITY as grouping levels, not tariff targets', () {
      expect(
        Zone.fromJson(<String, dynamic>{'id': '2', 'level': 'PROVINCE'})
            .isLeafZone,
        isFalse,
      );
      expect(
        Zone.fromJson(<String, dynamic>{'id': '22', 'level': 'CITY'})
            .isLeafZone,
        isFalse,
      );
    });
  });

  group('ShippingRateLoadSuccess', () {
    const List<Zone> zones = <Zone>[
      Zone(id: 2, name: 'Jawa Barat', level: 'PROVINCE'),
      Zone(id: 22, name: 'Bekasi', level: 'CITY', parentId: 2),
      Zone(id: 109, name: 'Bekasi Kabupaten', level: 'ZONE', parentId: 22),
      Zone(id: 108, name: 'Bekasi Kota', level: 'ZONE', parentId: 22),
    ];

    const state = ShippingRateLoadSuccess(
      rates: <ShippingRate>[],
      zones: zones,
      fleetTypes: <FleetType>[],
    );

    test('offers only leaf zones for a tariff row', () {
      expect(state.selectableZones.map((z) => z.id), <int>[109, 108]);
    });

    test('renders the parent chain so leaf names are unambiguous', () {
      expect(
        state.zonePathLabel(zones.last),
        'Jawa Barat › Bekasi › Bekasi Kota',
      );
    });

    test('falls back to the raw id for a zone it does not know', () {
      expect(state.zoneNameFor(999), 'Zona 999');
    });

    test('does not hang on a parent cycle in the data', () {
      const cyclic = ShippingRateLoadSuccess(
        rates: <ShippingRate>[],
        zones: <Zone>[
          Zone(id: 1, name: 'A', level: 'ZONE', parentId: 2),
          Zone(id: 2, name: 'B', level: 'CITY', parentId: 1),
        ],
        fleetTypes: <FleetType>[],
      );

      expect(cyclic.zonePathLabel(cyclic.zones.first), contains('A'));
    });
  });

  group('ShippingRate.fromJson', () {
    test('reads the DECIMAL columns the server sends as "750000.00"', () {
      // Live response shape. `int.tryParse("750000.00")` fails outright, so
      // this only works because asInt falls through to a double parse.
      final rate = ShippingRate.fromJson(<String, dynamic>{
        'id': '1',
        'seller_id': '2',
        'zone_id': '108',
        'fleet_type_code': 'CDD',
        'mode': 'SIMPLE',
        'base_rate': '750000.00',
        'kuli_bongkar_fee': '150000.00',
        'lantai_atas_fee': '0.00',
        'akses_sulit_fee': '0.00',
      });

      expect(rate.id, 1);
      expect(rate.zoneId, 108);
      expect(rate.baseRate, 750000);
      expect(rate.kuliBongkarFee, 150000);
      expect(rate.totalSurcharge, 150000);
    });

    test('sums the declared surcharges', () {
      final rate = ShippingRate.fromJson(<String, dynamic>{
        'id': '4',
        'zone_id': '12',
        'fleet_type_code': 'CDD',
        'base_rate': '750000',
        'kuli_bongkar_fee': '150000',
        'lantai_atas_fee': '100000',
        'akses_sulit_fee': '0',
      });

      expect(rate.baseRate, 750000);
      expect(rate.totalSurcharge, 250000);
    });
  });
}
