import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/models/project.dart';
import '../auth/auth_provider.dart';

/// Loads projects only after auth has finished resolving. Avoids the first
/// `/projects` request firing while JWT is still restoring (401 + stuck error
/// until full reload).
final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return <Project>[];

  // Await storage/cache explicitly, then set the header on this request. The
  // interceptor can still race flutter_secure_storage on web right after
  // navigation; a direct header guarantees the first dashboard load works.
  final token = await ApiClient.instance.getToken();
  if (token == null || token.isEmpty) return <Project>[];

  final resp = await ApiClient.instance.dio.get<List<dynamic>>(
    '/projects',
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );
  return (resp.data ?? [])
      .map((p) => Project.fromJson(p as Map<String, dynamic>))
      .toList();
});
