import 'package:flutter/material.dart';
import '../../core/models/task.dart';
import '../../core/theme/app_theme.dart';

// ── Kanban Card ───────────────────────────────────────────────────────────────

class KanbanCard extends StatelessWidget {
  const KanbanCard({super.key, required this.task, this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VibColors.surface,
      borderRadius: VibRadius.md,
      elevation: 0,
      child: InkWell(
        borderRadius: VibRadius.md,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: VibRadius.md,
            border: Border.all(color: VibColors.border),
            boxShadow: VibShadow.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PriorityDot(priority: task.priority),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: VibColors.navyDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  task.description!,
                  style: const TextStyle(
                      fontSize: 11, color: VibColors.textMid),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    task.wbsPos,
                    style: const TextStyle(
                        fontSize: 10,
                        color: VibColors.textLight,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (task.endDate != null)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 10, color: VibColors.textLight),
                        const SizedBox(width: 3),
                        Text(
                          _fmt(task.endDate!),
                          style: const TextStyle(
                              fontSize: 10, color: VibColors.textLight),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.priority});
  final String priority;

  static const _colors = {
    'critical': VibColors.danger,
    'high': VibColors.brand,
    'medium': VibColors.teal,
    'low': VibColors.textLight,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[priority] ?? VibColors.textLight;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
