import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/models/task.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/vib_button.dart';
import 'task_form_dialog.dart';

// ── Task Detail Panel ─────────────────────────────────────────────────────────

class TaskDetailPanel extends StatelessWidget {
  const TaskDetailPanel({
    super.key,
    required this.task,
    required this.onClose,
    required this.onUpdated,
  });

  final Task task;
  final VoidCallback onClose;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VibColors.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClose,
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('WBS: ${task.wbsPos}',
              style: Theme.of(context).textTheme.bodySmall),
          const Divider(height: 24),

          // Status + Priority row
          Row(
            children: [
              _Field(
                label: 'Status',
                child: _StatusDropdown(
                  value: task.status,
                  onChanged: (s) => _patchStatus(context, s),
                ),
              ),
              const SizedBox(width: 24),
              _Field(
                label: 'Priority',
                child: _PriorityDropdown(
                  value: task.priority,
                  onChanged: (p) => _patchPriority(context, p),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (task.startDate != null || task.endDate != null)
            Row(
              children: [
                if (task.startDate != null)
                  _Field(
                    label: 'Start',
                    child: Text(_fmt(task.startDate!),
                        style: const TextStyle(fontSize: 13)),
                  ),
                if (task.startDate != null && task.endDate != null)
                  const SizedBox(width: 24),
                if (task.endDate != null)
                  _Field(
                    label: 'End',
                    child: Text(_fmt(task.endDate!),
                        style: const TextStyle(fontSize: 13)),
                  ),
              ],
            ),

          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _Field(
              label: 'Description',
              child: Text(
                task.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],

          const Spacer(),

          // Actions
          Row(
            children: [
              VibButton(
                label: 'Edit Task',
                variant: VibButtonVariant.secondary,
                icon: Icons.edit_outlined,
                onPressed: () => _showEdit(context),
              ),
              const SizedBox(width: 8),
              VibButton(
                label: 'Delete',
                variant: VibButtonVariant.danger,
                icon: Icons.delete_outline,
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _patchStatus(BuildContext context, String status) async {
    try {
      await ApiClient.instance.dio
          .patch('/tasks/${task.id}', data: {'status': status});
      onUpdated();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _patchPriority(BuildContext context, String priority) async {
    try {
      await ApiClient.instance.dio
          .patch('/tasks/${task.id}', data: {'priority': priority});
      onUpdated();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showEdit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => TaskFormDialog(
        projectId: task.projectId,
        task: task,
        onSaved: onUpdated,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          VibButton(
            label: 'Delete',
            variant: VibButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ApiClient.instance.dio.delete('/tasks/${task.id}');
        onUpdated();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Field ─────────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: VibColors.textLight,
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

// ── Status Dropdown ───────────────────────────────────────────────────────────

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      isDense: true,
      items: ['todo', 'in_progress', 'in_review', 'done']
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (v) => v != null ? onChanged(v) : null,
    );
  }
}

// ── Priority Dropdown ─────────────────────────────────────────────────────────

class _PriorityDropdown extends StatelessWidget {
  const _PriorityDropdown({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      isDense: true,
      items: ['critical', 'high', 'medium', 'low']
          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
          .toList(),
      onChanged: (v) => v != null ? onChanged(v) : null,
    );
  }
}
