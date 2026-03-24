import 'package:flutter/material.dart';
import '../../core/models/task.dart';
import '../../core/theme/app_theme.dart';

// ── WBS Tree ──────────────────────────────────────────────────────────────────

class WbsTree extends StatefulWidget {
  const WbsTree({
    super.key,
    required this.tasks,
    this.selectedId,
    required this.onSelect,
  });

  final List<Task> tasks;
  final String? selectedId;
  final ValueChanged<Task> onSelect;

  @override
  State<WbsTree> createState() => _WbsTreeState();
}

class _WbsTreeState extends State<WbsTree> {
  final _expanded = <String>{};

  @override
  void initState() {
    super.initState();
    // Expand all top-level by default
    for (final t in widget.tasks) {
      _expanded.add(t.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VibColors.surface,
      child: Column(
        children: [
          _TreeHeader(),
          Expanded(
            child: ListView(
              children: widget.tasks
                  .map((t) => _TreeNode(
                        task: t,
                        depth: 0,
                        expanded: _expanded,
                        selectedId: widget.selectedId,
                        onSelect: widget.onSelect,
                        onToggle: (id) => setState(() {
                          if (_expanded.contains(id)) {
                            _expanded.remove(id);
                          } else {
                            _expanded.add(id);
                          }
                        }),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tree Header ───────────────────────────────────────────────────────────────

class _TreeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: VibColors.bg,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          SizedBox(width: 200, child: Text('Task', style: _hStyle)),
          SizedBox(width: 80, child: Text('Status', style: _hStyle)),
          SizedBox(width: 80, child: Text('Priority', style: _hStyle)),
          SizedBox(width: 80, child: Text('Assignee', style: _hStyle)),
          SizedBox(width: 100, child: Text('Due Date', style: _hStyle)),
        ],
      ),
    );
  }

  static const _hStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: VibColors.textLight,
    letterSpacing: 0.3,
  );
}

// ── Tree Node ─────────────────────────────────────────────────────────────────

class _TreeNode extends StatelessWidget {
  const _TreeNode({
    required this.task,
    required this.depth,
    required this.expanded,
    required this.selectedId,
    required this.onSelect,
    required this.onToggle,
  });

  final Task task;
  final int depth;
  final Set<String> expanded;
  final String? selectedId;
  final ValueChanged<Task> onSelect;
  final ValueChanged<String> onToggle;

  bool get _isExpanded => expanded.contains(task.id);
  bool get _hasChildren => task.children.isNotEmpty;
  bool get _isSelected => task.id == selectedId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row
        GestureDetector(
          onTap: () => onSelect(task),
          child: Container(
            height: 40,
            color: _isSelected
                ? VibColors.brand.withValues(alpha: 0.08)
                : Colors.transparent,
            padding: EdgeInsets.only(left: 16.0 + depth * 20),
            child: Row(
              children: [
                // Expand icon
                SizedBox(
                  width: 20,
                  child: _hasChildren
                      ? GestureDetector(
                          onTap: () => onToggle(task.id),
                          child: Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_right,
                            size: 18,
                            color: VibColors.textMid,
                          ),
                        )
                      : null,
                ),
                // Milestone diamond
                if (task.isMilestone)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: VibColors.brand,
                      borderRadius: BorderRadius.circular(2),
                      shape: BoxShape.rectangle,
                    ),
                    transform: Matrix4.rotationZ(0.785398),
                  ),
                // WBS pos
                SizedBox(
                  width: 40,
                  child: Text(
                    task.wbsPos,
                    style: const TextStyle(
                        fontSize: 10,
                        color: VibColors.textLight,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                // Title
                SizedBox(
                  width: 140,
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: depth == 0
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: VibColors.navyDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: _StatusChip(status: task.status),
                ),
                SizedBox(
                  width: 80,
                  child: _PriorityChip(priority: task.priority),
                ),
                const SizedBox(width: 80), // assignee
                SizedBox(
                  width: 100,
                  child: task.endDate != null
                      ? Text(
                          _fmt(task.endDate!),
                          style: const TextStyle(
                              fontSize: 11, color: VibColors.textMid),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        // Children
        if (_isExpanded)
          ...task.children.map(
            (child) => _TreeNode(
              task: child,
              depth: depth + 1,
              expanded: expanded,
              selectedId: selectedId,
              onSelect: onSelect,
              onToggle: onToggle,
            ),
          ),
      ],
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

// ── Chips ─────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  static const _map = {
    'todo': (Color(0xFF999999), 'To Do'),
    'in_progress': (VibColors.brand, 'In Progress'),
    'in_review': (Color(0xFF7B2CBF), 'In Review'),
    'done': (VibColors.teal, 'Done'),
  };

  @override
  Widget build(BuildContext context) {
    final (color, label) = _map[status] ?? (VibColors.textLight, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: VibRadius.pill,
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});
  final String priority;

  static const _map = {
    'critical': (VibColors.danger, 'Critical'),
    'high': (VibColors.brand, 'High'),
    'medium': (VibColors.teal, 'Medium'),
    'low': (VibColors.textLight, 'Low'),
  };

  @override
  Widget build(BuildContext context) {
    final (color, label) = _map[priority] ?? (VibColors.textLight, priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: VibRadius.pill,
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
