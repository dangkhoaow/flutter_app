import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ── ApiClient ─────────────────────────────────────────────────────────────────

const _baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:3000/api',
);

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _tokenKey = 'jwt_token';
  final _storage = const FlutterSecureStorage();

  /// In-memory JWT so the next request after login always has a token. On web,
  /// `flutter_secure_storage` can briefly not return a value on read right after write;
  /// that caused the first post-login `/projects` call to go out without `Authorization`
  /// (401 + blank dashboard until full reload).
  String? _tokenCache;
  Completer<void>? _tokenReadyCompleter;

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

  void _logAuth(String message) {
    debugPrint('[ApiClient] $message');
  }

  void _setAuthHeader(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
      return;
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Dio _buildDio() {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        var token = _tokenCache;
        if (token == null || token.isEmpty) {
          token = await _storage.read(key: _tokenKey);
          _tokenCache = token;
        }
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        final hasAuth = (options.headers['Authorization'] ?? '')
            .toString()
            .isNotEmpty;
        _logAuth('request ${options.method} ${options.path} auth=$hasAuth');
        handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Only drop the session if we actually sent a token and the server rejected it.
        // If 401 happened because the header was missing (storage race), clearing would
        // delete a valid token and make the bug worse.
        if (error.response?.statusCode == 401) {
          final h = error.requestOptions.headers;
          final auth = h['Authorization'] ?? h['authorization'];
          final sent = auth is String ? auth : (auth is List ? auth.join() : '');
          if (sent.isEmpty && error.requestOptions.extra['retryAuth'] != true) {
            final token = await ensureToken();
            if (token != null && token.isNotEmpty) {
              final opts = error.requestOptions;
              opts.extra['retryAuth'] = true;
              opts.headers['Authorization'] = 'Bearer $token';
              _logAuth(
                  'retry 401 ${opts.method} ${opts.path} after token ready');
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (_) {}
            }
          }
          if (sent.isNotEmpty) {
            await clearToken();
          }
        }
        handler.next(error);
      },
    ));


    return dio;
  }

  Future<void> saveToken(String token) async {
    _tokenCache = token;
    _setAuthHeader(token);
    _tokenReadyCompleter?.complete();
    _tokenReadyCompleter = null;
    _logAuth('saveToken cached len=${token.length}');
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    _tokenCache = null;
    _setAuthHeader(null);
    _tokenReadyCompleter = null;
    _logAuth('clearToken cached len=0');
    await _storage.delete(key: _tokenKey);
  }

  Future<String?> getToken() async {
    if (_tokenCache != null && _tokenCache!.isNotEmpty) return _tokenCache;
    final t = await _storage.read(key: _tokenKey);
    _tokenCache = t;
    _setAuthHeader(t);
    _logAuth('getToken cached len=${t?.length ?? 0}');
    return t;
  }

  Future<String?> ensureToken({
    Duration timeout = const Duration(milliseconds: 600),
  }) async {
    var token = _tokenCache;
    if (token != null && token.isNotEmpty) {
      _setAuthHeader(token);
      return token;
    }

    token = await _storage.read(key: _tokenKey);
    _tokenCache = token;
    if (token != null && token.isNotEmpty) {
      _setAuthHeader(token);
      _logAuth('ensureToken read len=${token.length}');
      return token;
    }

    _tokenReadyCompleter ??= Completer<void>();
    try {
      await _tokenReadyCompleter!.future.timeout(timeout);
    } catch (_) {}

    token = _tokenCache;
    if (token != null && token.isNotEmpty) {
      _setAuthHeader(token);
      _logAuth('ensureToken waited len=${token.length}');
    } else {
      _logAuth('ensureToken timed out len=0');
    }
    return token;
  }

  Future<bool> hasToken() async {
    if (_tokenCache != null && _tokenCache!.isNotEmpty) return true;
    final t = await _storage.read(key: _tokenKey);
    _tokenCache = t;
    _setAuthHeader(t);
    _logAuth('hasToken cached len=${t?.length ?? 0}');
    return t != null && t.isNotEmpty;
  }
}
