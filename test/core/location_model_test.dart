import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/core/domain/model/inventory/warehouse.dart';
import 'package:navy_wear/core/domain/model/location/master_location.dart';

/// Payloads captured from the running marketplace API.
void main() {
  group('MasterProvince / MasterCity', () {
    // These two endpoints do not follow the rest of the API's naming, which is
    // the whole reason they need pinning: `province_name` not `name`, `active`
    // not `is_active`, `created_date` not `created_at`.
    test('a province reads its oddly named fields', () {
      final province = MasterProvince.fromJson(<String, dynamic>{
        'id': '4',
        'province_name': 'DKI Jakarta',
        'active': '1',
        'created_by': null,
        'created_date': '2026-09-21 08:14:47',
        'modified_by': null,
        'modified_date': null,
      });

      expect(province.id, 4);
      expect(province.name, 'DKI Jakarta');
      expect(province.isActive, isTrue);
    });

    test('a city reads its province link', () {
      final city = MasterCity.fromJson(<String, dynamic>{
        'id': '7',
        'city_name': 'Bandung',
        'province_id': '5',
        'active': '1',
        'created_by': null,
        'created_date': '2026-09-21 08:14:47',
        'modified_by': null,
        'modified_date': null,
      });

      expect(city.id, 7);
      expect(city.name, 'Bandung');
      expect(city.provinceId, 5);
      expect(city.isActive, isTrue);
    });

    test('a name read from the usual key would come back empty', () {
      // Guards the mistake this shape invites: reading `name`, getting '', and
      // rendering a dropdown of blanks rather than failing.
      final province = MasterProvince.fromJson(<String, dynamic>{
        'id': '1',
        'name': 'Aceh',
      });

      expect(province.name, isEmpty,
          reason: 'the payload key is province_name, not name');
    });
  });

  group('Warehouse.cityId', () {
    Map<String, dynamic> row({dynamic cityId}) => <String, dynamic>{
          'id': '15',
          'store_id': '20',
          'name': 'Gudang V13',
          'address': 'Jl. Uji 1',
          'city': 'Jakarta Timur',
          'province': 'DKI Jakarta',
          'city_id': cityId,
          'postal_code': '13920',
          'latitude': null,
          'longitude': null,
          'is_default': '1',
          'status': 'active',
          'created_at': '2026-09-21 12:07:07',
        };

    test('reads the master-data link added in v1.2.0', () {
      expect(Warehouse.fromJson(row(cityId: '9')).cityId, 9);
    });

    test('a warehouse named by free text alone has no city_id', () {
      // Nullable on purpose: the master list is a small seed and does not
      // cover every address, so the text columns were kept. "Jakarta Timur"
      // is exactly such a case — it is not in the master list.
      final warehouse = Warehouse.fromJson(row());

      expect(warehouse.cityId, isNull);
      expect(warehouse.city, 'Jakarta Timur');
      expect(warehouse.shortAddress, 'Jakarta Timur, DKI Jakarta');
    });
  });
}
