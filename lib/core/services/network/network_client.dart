import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../app/urls.dart';
import '../../../core/services/network/network_response.dart';
import '../../../core/services/session/session.dart';

class NetworkClient {
  NetworkClient({String? baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? Urls.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 25),
            sendTimeout: const Duration(seconds: 25),
            headers: {'Accept': 'application/json'},
            // We map status codes ourselves instead of throwing on 4xx/5xx.
            validateStatus: (code) => code != null && code < 600,
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) {
        final token = Session.instance.token;
        if (token != null && options.extra['auth'] != false) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      }),
    );
    if (kDebugMode) {
      // Only method + URL + status. Never log headers or bodies (tokens, passwords).
      _dio.interceptors.add(LogInterceptor(
        request: false,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
        logPrint: (o) => debugPrint(o.toString()),
      ));
    }
  }

  final Dio _dio;

  /// [auth] = false for public calls (login/register) so a 401 is not treated as an expired session.
  Future<NetworkResponse> request(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    bool auth = true,
  }) async {
    try {
      final cleanQuery = <String, dynamic>{
        for (final e in (query ?? const <String, dynamic>{}).entries)
          if (e.value != null && e.value.toString().isNotEmpty) e.key: e.value,
      };
      final res = await _dio.request(
        path,
        data: body,
        queryParameters: cleanQuery.isEmpty ? null : cleanQuery,
        options: Options(method: method, extra: {'auth': auth}),
      );
      return _parse(res, auth);
    } on DioException catch (e) {
      return _fail(e);
    } catch (_) {
      return const NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  NetworkResponse _parse(Response res, bool auth) {
    final code = res.statusCode ?? -1;
    final body = res.data;
    final map = body is Map ? body : const <dynamic, dynamic>{};
    final ok = code >= 200 && code < 300 && map['success'] != false;

    if (code == 401 && auth && Session.instance.hasToken) {
      Session.instance.expire();
    }

    final rawErrors = map['errors'];
    final errors = rawErrors is List
        ? rawErrors.map((e) => e is Map ? (e['message'] ?? '').toString() : e.toString()).where((s) => s.isNotEmpty).toList()
        : <String>[];

    return NetworkResponse(
      isSuccess: ok,
      statusCode: code,
      data: map['data'],
      message: (map['message'] ?? (ok ? 'Success' : 'Request failed (HTTP $code)')).toString(),
      errors: errors,
      code: map['code']?.toString(),
    );
  }

  NetworkResponse _fail(DioException e) {
    final message = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'The server is taking too long to respond. Please try again.',
      DioExceptionType.connectionError => 'Cannot reach the server. Check your internet connection.',
      DioExceptionType.cancel => 'Request cancelled.',
      _ => 'Something went wrong. Please try again.',
    };
    return NetworkResponse(isSuccess: false, statusCode: -1, message: message);
  }
}
