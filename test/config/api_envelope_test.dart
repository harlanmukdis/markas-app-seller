import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navy_wear/config/network/api_envelope.dart';
import 'package:navy_wear/config/network/api_exception.dart';
import 'package:navy_wear/core/data_state.dart';

Response<dynamic> _response(dynamic body, {int status = 200}) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/sellers/1'),
      data: body,
      statusCode: status,
    );

void main() {
  group('ApiEnvelope', () {
    test('unwraps a success envelope carrying an object', () {
      final envelope = ApiEnvelope.from(
        _response(<String, dynamic>{
          'success': true,
          'data': <String, dynamic>{'id': '1', 'name': 'Toko Jaya'},
          'error': null,
        }),
      );

      expect(envelope.map['name'], 'Toko Jaya');
    });

    test('exposes the meta block on a paginated list', () {
      final envelope = ApiEnvelope.from(
        _response(<String, dynamic>{
          'success': true,
          'data': <dynamic>[
            <String, dynamic>{'id': '1'},
          ],
          'error': null,
          'meta': <String, dynamic>{'limit': 50, 'offset': 0},
        }),
      );

      expect(envelope.list, hasLength(1));
      expect(envelope.limit, 50);
      expect(envelope.offset, 0);
    });

    test('throws with the backend code when success is false on a 2xx', () {
      expect(
        () => ApiEnvelope.from(
          _response(<String, dynamic>{
            'success': false,
            'data': null,
            'error': <String, dynamic>{
              'code': 'VALIDATION_ERROR',
              'message': 'Field wajib kosong',
              'details': <String, dynamic>{
                'missing': <String>['qty'],
              },
            },
          }),
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 'VALIDATION_ERROR')
              .having(
                (e) => e.details?['missing'],
                'details.missing',
                <String>['qty'],
              ),
        ),
      );
    });

    test('throws a parse error when the body is not an envelope at all', () {
      // CodeIgniter answers an unrouted path with a bare string rather than
      // the JSON envelope.
      expect(
        () => ApiEnvelope.from(_response('Endpoint not found', status: 404)),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', DataErrorCode.parse),
        ),
      );
    });

    test('listAt falls back to a keyed array when data is an object', () {
      final envelope = ApiEnvelope.from(
        _response(<String, dynamic>{
          'success': true,
          'data': <String, dynamic>{
            'warehouses': <dynamic>[
              <String, dynamic>{'id': '1', 'name': 'Gudang Utama'},
            ],
          },
          'error': null,
        }),
      );

      expect(envelope.listAt('warehouses'), hasLength(1));
    });
  });

  group('ApiException.fromDio', () {
    test('prefers the envelope error over Dio generic text', () {
      final exception = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/offers/1/activate'),
          response: _response(
            <String, dynamic>{
              'success': false,
              'data': null,
              'error': <String, dynamic>{
                'code': 'GATES_NOT_PASSED',
                'message': 'Syarat aktivasi belum terpenuhi',
                'details': <String, dynamic>{'photos_ok': false},
              },
            },
            status: 422,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(exception.code, 'GATES_NOT_PASSED');
      expect(exception.statusCode, 422);
      expect(exception.details?['photos_ok'], isFalse);
    });

    test('maps a connection failure to a message that names the base URL', () {
      final options = RequestOptions(
        path: '/auth/login',
        baseUrl: 'http://localhost/markas/api/v1',
      );

      final exception = ApiException.fromDio(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );

      expect(exception.code, DataErrorCode.network);
      expect(exception.message, contains('http://localhost/markas/api/v1'));
      // On web a blocked CORS preflight is indistinguishable from a dead
      // server, so the message has to mention both.
      expect(exception.message, contains('CORS'));
    });

    test('converts cleanly into a DataError for the UI', () {
      final error = const ApiException(
        code: 'NO_SELLER_CONTEXT',
        message: 'Akun tidak terhubung ke toko',
        statusCode: 403,
      ).toDataError();

      expect(error.isNoSellerContext, isTrue);
      expect(error.statusCode, 403);
    });
  });
}
