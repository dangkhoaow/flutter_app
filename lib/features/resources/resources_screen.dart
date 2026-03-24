import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/models/allocation.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/top_bar.dart';
import '../../shared/widgets/vib_card.dart';
import 'heatmap_widget.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final heatmapProvider = FutureProvider<List<HeatmapRow>>((ref) async {
  final resp = await ApiClient.instance.dio.get('/resources/heatmap');
  return (resp.data as List)
      .map((r) => HeatmapRow.fromJson(r as Map<String, dynamic>))
      .toList();
});

// ── Resources Screen ──────────────────────────────────────────────────────────

class ResourcesScreen extends ConsumerWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heatmapAsync = ref.watch(heatmapProvider);

    return Scaffold(
      appBar: const TopBar(title: 'Resource Management'),
      backgroundColor: VibColors.bg,
      body: heatmapAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rows) => _ResourcesBody(
          rows: rows,
          onUpdated: () => ref.invalidate(heatmapProvider),
        ),
      ),
    );
  }
}

// ── Resources Body ────────────────────────────────────────────────────────────

class _ResourcesBody extends StatelessWidget {
  const _ResourcesBody({required this.rows, required this.onUpdated});
  final List<HeatmapRow> rows;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context) {
    final avgUtil = rows.isEmpty
        ? 0
        : (rows
                    .expand((r) => r.weeks)
                    .fold(0, (a, b) => a + b) /
                (rows.length * (rows.first.weeks.length)))
            .round();

    final overloaded = rows.where((r) => r.weeks.any((w) => w > 100)).length;
    final available = rows.where((r) => r.weeks.any((w) => w < 40)).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI cards
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Avg Utilisation',
                  value: '$avgUtil%',
                  icon: Icons.speed_outlined,
                  gradient: VibColors.gradNavy,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCard(
                  label: 'Overloaded (>100%)',
                  value: overloaded.toString(),
                  icon: Icons.warning_amber_outlined,
                  gradient: VibColors.gradDanger,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCard(
                  label: 'On Track',
                  value: (rows.length - overloaded - available).toString(),
                  icon: Icons.check_circle_outline,
                  gradient: VibColors.gradTeal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCard(
                  label: 'Available (<40%)',
                  value: available.toString(),
                  icon: Icons.person_outline,
                  gradient: LinearGradient(
                    colors: [VibColors.textMid, const Color(0xFF888888)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Text('Utilisation Heatmap',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Click any cell to edit allocation. Green = available, Yellow = normal, Orange = high, Red = overloaded.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          HeatmapWidget(rows: rows, onUpdated: onUpdated),
        ],
      ),
    );
  }
}
