import 'package:dio/dio.dart';
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

  late final Dio _dio = _buildDio();

  Dio get dio => _dio;

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
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    _tokenCache = null;
    await _storage.delete(key: _tokenKey);
  }

  Future<String?> getToken() async {
    if (_tokenCache != null && _tokenCache!.isNotEmpty) return _tokenCache;
    final t = await _storage.read(key: _tokenKey);
    _tokenCache = t;
    return t;
  }

  Future<bool> hasToken() async {
    if (_tokenCache != null && _tokenCache!.isNotEmpty) return true;
    final t = await _storage.read(key: _tokenKey);
    _tokenCache = t;
    return t != null && t.isNotEmpty;
  }
}
