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
          'meta': <String, dynamic>{'page': 1, 'per_page': 20, 'total': 100},
        }),
      );

      expect(envelope.list, hasLength(1));
      expect(envelope.page, 1);
      expect(envelope.perPage, 20);
      expect(envelope.total, 100);
    });

    test('reads the facets block GET /products adds to meta', () {
      final envelope = ApiEnvelope.from(
        _response(<String, dynamic>{
          'success': true,
          'data': <dynamic>[],
          'error': null,
          'meta': <String, dynamic>{
            'page': 1,
            'per_page': 20,
            'total': 0,
            'facets': <String, dynamic>{
              'rating': <dynamic>[
                <String, dynamic>{'min_rating': 5, 'count': 0},
              ],
            },
          },
        }),
      );

      expect(envelope.facets?['rating'], hasLength(1));
    });

    test('reports null pagination for a list endpoint that sends no meta', () {
      // GET /stores/{id}/products answers with a bare array — the seller-side
      // list screens cannot read a total off the server.
      final envelope = ApiEnvelope.from(
        _response(<String, dynamic>{
          'success': true,
          'data': <dynamic>[
            <String, dynamic>{'id': '1'},
          ],
          'error': null,
        }),
      );

      expect(envelope.list, hasLength(1));
      expect(envelope.page, isNull);
      expect(envelope.total, isNull);
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
      // Real response from POST /stores/{id}/wallet/withdraw on a store whose
      // balance is still 0.00.
      final exception = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/stores/11/wallet/withdraw'),
          response: _response(
            <String, dynamic>{
              'success': false,
              'data': null,
              'error': <String, dynamic>{
                'code': 'WITHDRAWAL_REJECTED',
                'message': 'Saldo tidak mencukupi',
                'details': <String, dynamic>{'balance': '0.00'},
              },
            },
            status: 422,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(exception.code, 'WITHDRAWAL_REJECTED');
      expect(exception.statusCode, 422);
      expect(exception.details?['balance'], '0.00');
    });

    test('keeps the REST layer wording when error is a bare string', () {
      // A route reached with a verb it does not implement never gets as far as
      // the envelope: DELETE /products/{id} answers 405 with the REST
      // library's own `{status, error}` shape, where `error` is a string.
      final exception = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/products/23'),
          response: _response(
            <String, dynamic>{'status': false, 'error': 'Unknown method'},
            status: 405,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(exception.message, 'Unknown method');
      expect(exception.statusCode, 405);
    });

    test('maps a connection failure to a message that names the base URL', () {
      final options = RequestOptions(
        path: '/auth/login',
        baseUrl: 'http://localhost:8000/api/v1',
      );

      final exception = ApiException.fromDio(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );

      expect(exception.code, DataErrorCode.network);
      expect(exception.message, contains('http://localhost:8000/api/v1'));
      // On web a blocked CORS preflight is indistinguishable from a dead
      // server, so the message has to mention both.
      expect(exception.message, contains('CORS'));
    });

    test('summarises an HTML error page instead of dumping it', () {
      // Real response from POST /warehouses/{id}/stock-in when
      // product_variant_id points at a row that does not exist: CodeIgniter's
      // unhandled database error escapes as a full HTML document, not the JSON
      // envelope.
      const html = '<!DOCTYPE html>\n<html lang="en">\n<head>\n'
          '<meta charset="utf-8">\n<title>Database Error</title>\n'
          '<style type="text/css">body { margin: 40px; }</style></head>'
          '<body><h1>A Database Error Occurred</h1></body></html>';

      final exception = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/sellers/2/warehouses'),
          response: _response(html, status: 500),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(exception.statusCode, 500);
      expect(exception.message, contains('Database Error'));
      expect(exception.message, contains('500'));
      // The point of the summary: no markup reaches the snackbar.
      expect(exception.message, isNot(contains('<')));
      expect(exception.message.length, lessThan(200));
    });

    test('passes a short plain-text body through unchanged', () {
      final exception = ApiException.fromDio(
        DioException(
          requestOptions: RequestOptions(path: '/returns/1'),
          response: _response('Endpoint not found', status: 404),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(exception.message, 'Endpoint not found');
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
