import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_client.dart';
import '../../core/models/project.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/top_bar.dart';
import '../../shared/widgets/vib_button.dart';
import '../../shared/widgets/vib_card.dart';
import 'project_card.dart';
import 'new_project_dialog.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final resp = await ApiClient.instance.dio.get('/projects');
  return (resp.data as List)
      .map((p) => Project.fromJson(p as Map<String, dynamic>))
      .toList();
});

// ── Dashboard Screen ──────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: TopBar(
        title: 'Dashboard',
        actions: [
          VibButton(
            label: 'New Project',
            icon: Icons.add,
            onPressed: () => _showNewProject(context, ref),
          ),
        ],
      ),
      backgroundColor: VibColors.bg,
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (projects) => _DashboardBody(projects: projects),
      ),
    );
  }

  void _showNewProject(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => NewProjectDialog(
        onCreated: () => ref.invalidate(projectsProvider),
      ),
    );
  }
}

// ── Dashboard Body ────────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.projects});
  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final active = projects.where((p) => p.status == 'active').length;
    final onHold = projects.where((p) => p.status == 'on_hold').length;
    final done = projects.where((p) => p.status == 'completed').length;
    final behind = projects.where((p) => p.isBehindSchedule).length;

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
                  label: 'Active Projects',
                  value: active.toString(),
                  icon: Icons.folder_open_outlined,
                  gradient: VibColors.gradNavy,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCard(
                  label: 'On Hold',
                  value: onHold.toString(),
                  icon: Icons.pause_circle_outline,
                  gradient: LinearGradient(
                    colors: [VibColors.textMid, const Color(0xFF888888)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCard(
                  label: 'Completed',
                  value: done.toString(),
                  icon: Icons.check_circle_outline,
                  gradient: VibColors.gradTeal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiCard(
                  label: 'Behind Schedule',
                  value: behind.toString(),
                  icon: Icons.warning_amber_outlined,
                  gradient: VibColors.gradDanger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Projects grid
          Text(
            'All Projects',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (projects.isEmpty)
            _EmptyState()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 340,
                mainAxisExtent: 180,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: projects.length,
              itemBuilder: (_, i) => ProjectCard(
                project: projects[i],
                onTap: () => context.go(
                  '/projects/${projects[i].id}/wbs',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.folder_outlined, size: 56, color: VibColors.textLight),
            const SizedBox(height: 16),
            Text('No projects yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Create your first project to get started.',
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
