import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/models/task.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/top_bar.dart';
import 'kanban_card.dart';

// ── Kanban columns ────────────────────────────────────────────────────────────

const _columns = [
  ('todo', 'To Do', Color(0xFF999999)),
  ('in_progress', 'In Progress', VibColors.brand),
  ('in_review', 'In Review', Color(0xFF7B2CBF)),
  ('done', 'Done', VibColors.teal),
];

// ── Kanban Screen ─────────────────────────────────────────────────────────────

class KanbanScreen extends ConsumerStatefulWidget {
  const KanbanScreen({super.key, required this.projectId});
  final String projectId;

  @override
  ConsumerState<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends ConsumerState<KanbanScreen> {
  List<Task> _tasks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final resp = await ApiClient.instance.dio
          .get('/projects/${widget.projectId}/tasks');
      setState(() {
        _tasks = (resp.data as List)
            .map((t) => Task.fromJson(t as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _moveTask(Task task, String newStatus) async {
    setState(() {
      _tasks = _tasks.map((t) => t.id == task.id ? t.copyWith(status: newStatus) : t).toList();
    });
    try {
      await ApiClient.instance.dio
          .patch('/tasks/${task.id}', data: {'status': newStatus});
    } catch (_) {
      // revert on error
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'Kanban Board'),
      backgroundColor: VibColors.bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _KanbanBoard(
                  tasks: _tasks,
                  onMove: _moveTask,
                ),
    );
  }
}

// ── Kanban Board ──────────────────────────────────────────────────────────────

class _KanbanBoard extends StatelessWidget {
  const _KanbanBoard({required this.tasks, required this.onMove});

  final List<Task> tasks;
  final Future<void> Function(Task task, String newStatus) onMove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _columns.map((col) {
          final (status, label, color) = col;
          final colTasks =
              tasks.where((t) => t.status == status).toList();
          return Expanded(
            child: _KanbanColumn(
              status: status,
              label: label,
              color: color,
              tasks: colTasks,
              onMove: onMove,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Kanban Column ─────────────────────────────────────────────────────────────

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.status,
    required this.label,
    required this.color,
    required this.tasks,
    required this.onMove,
  });

  final String status;
  final String label;
  final Color color;
  final List<Task> tasks;
  final Future<void> Function(Task, String) onMove;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onWillAcceptWithDetails: (data) => data.data.status != status,
      onAcceptWithDetails: (data) => onMove(data.data, status),
      builder: (context, candidates, rejected) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: candidates.isNotEmpty
                ? color.withValues(alpha: 0.06)
                : VibColors.bg,
            borderRadius: VibRadius.lg,
            border: Border.all(
              color: candidates.isNotEmpty
                  ? color.withValues(alpha: 0.5)
                  : VibColors.border,
              width: candidates.isNotEmpty ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              // Column header
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: VibRadius.pill,
                      ),
                      child: Text(
                        tasks.length.toString(),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Cards
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final t = tasks[i];
                    return LongPressDraggable<Task>(
                      data: t,
                      feedback: Material(
                        elevation: 8,
                        borderRadius: VibRadius.md,
                        child: SizedBox(
                          width: 200,
                          child: KanbanCard(task: t),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: KanbanCard(task: t),
                      ),
                      child: KanbanCard(task: t),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
