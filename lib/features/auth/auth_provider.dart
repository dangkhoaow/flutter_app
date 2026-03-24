import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/models/user.dart';

// ── Auth State ────────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final hasToken = await ApiClient.instance.hasToken();
    if (!hasToken) return null;
    return _fetchMe();
  }

  Future<User?> _fetchMe() async {
    try {
      final resp = await ApiClient.instance.dio.get('/auth/me');
      return User.fromJson(resp.data as Map<String, dynamic>);
    } catch (_) {
      await ApiClient.instance.clearToken();
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final resp = await ApiClient.instance.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final token = resp.data['token'] as String;
      await ApiClient.instance.saveToken(token);
      return User.fromJson(resp.data['user'] as Map<String, dynamic>);
    });
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.dio.post('/auth/logout');
    } catch (_) {}
    await ApiClient.instance.clearToken();
    state = const AsyncData(null);
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

// ── Users list (admin) ────────────────────────────────────────────────────────

final usersProvider = FutureProvider<List<User>>((ref) async {
  final resp = await ApiClient.instance.dio.get('/admin/users');
  return (resp.data as List)
      .map((u) => User.fromJson(u as Map<String, dynamic>))
      .toList();
});
