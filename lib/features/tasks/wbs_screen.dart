import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/models/task.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/top_bar.dart';
import '../../shared/widgets/vib_button.dart';
import 'wbs_tree.dart';
import 'task_detail_panel.dart';
import 'task_form_dialog.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final wbsTasksProvider =
    FutureProvider.family<List<Task>, String>((ref, projectId) async {
  final resp =
      await ApiClient.instance.dio.get('/projects/$projectId/tasks/tree');
  return (resp.data as List)
      .map((t) => Task.fromJson(t as Map<String, dynamic>))
      .toList();
});

final selectedTaskProvider = StateProvider<Task?>((ref) => null);

// ── WBS Screen ────────────────────────────────────────────────────────────────

class WbsScreen extends ConsumerWidget {
  const WbsScreen({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(wbsTasksProvider(projectId));
    final selectedTask = ref.watch(selectedTaskProvider);

    return Scaffold(
      appBar: TopBar(
        title: 'Work Breakdown Structure',
        actions: [
          VibButton(
            label: 'Add Task',
            icon: Icons.add,
            onPressed: () => _showAddTask(context, ref),
          ),
        ],
      ),
      backgroundColor: VibColors.bg,
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) => Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // WBS Tree: must use Expanded in Row — double.infinity width is invalid here and
            // leaves the tree with zero / broken layout on web when no detail panel is open.
            if (selectedTask != null)
              SizedBox(
                width: 480,
                child: WbsTree(
                  tasks: tasks,
                  selectedId: selectedTask.id,
                  onSelect: (t) =>
                      ref.read(selectedTaskProvider.notifier).state = t,
                ),
              )
            else
              Expanded(
                child: WbsTree(
                  tasks: tasks,
                  selectedId: null,
                  onSelect: (t) =>
                      ref.read(selectedTaskProvider.notifier).state = t,
                ),
              ),
            if (selectedTask != null) ...[
              const VerticalDivider(width: 1),
              Expanded(
                child: TaskDetailPanel(
                  task: selectedTask,
                  onClose: () =>
                      ref.read(selectedTaskProvider.notifier).state = null,
                  onUpdated: () {
                    ref.invalidate(wbsTasksProvider(projectId));
                    ref.read(selectedTaskProvider.notifier).state = null;
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddTask(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => TaskFormDialog(
        projectId: projectId,
        onSaved: () => ref.invalidate(wbsTasksProvider(projectId)),
      ),
    );
  }
}
