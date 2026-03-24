import 'package:flutter/material.dart';
import '../../core/models/allocation.dart';
import '../../core/theme/app_theme.dart';
import 'alloc_edit_dialog.dart';

// ── Heatmap Widget ────────────────────────────────────────────────────────────

class HeatmapWidget extends StatelessWidget {
  const HeatmapWidget({super.key, required this.rows, required this.onUpdated});

  final List<HeatmapRow> rows;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context) {
    final weekCount = rows.isNotEmpty ? rows.first.weeks.length : 12;

    return Container(
      decoration: BoxDecoration(
        color: VibColors.surface,
        borderRadius: VibRadius.md,
        border: Border.all(color: VibColors.border),
        boxShadow: VibShadow.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                _NameCell(label: 'Member', header: true),
                _RoleCell(label: 'Role', header: true),
                ...List.generate(
                  weekCount,
                  (i) => _WeekCell(label: 'W${i + 1}', header: true),
                ),
              ],
            ),
            const Divider(height: 1),
            // Data rows
            ...rows.map(
              (row) => Column(
                children: [
                  Row(
                    children: [
                      _NameCell(label: row.userName),
                      _RoleCell(label: row.userRole),
                      ...List.generate(
                        row.weeks.length,
                        (wi) => _HeatCell(
                          value: row.weeks[wi],
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => AllocEditDialog(
                              memberName: row.userName,
                              userId: row.userId,
                              weekIndex: wi,
                              currentValue: row.weeks[wi],
                              onSaved: onUpdated,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header cells ──────────────────────────────────────────────────────────────

class _NameCell extends StatelessWidget {
  const _NameCell({required this.label, this.header = false});
  final String label;
  final bool header;

  @override
  Widget build(BuildContext context) => Container(
        width: 160,
        height: 40,
        color: header ? VibColors.bg : VibColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            fontSize: header ? 10 : 13,
            fontWeight: header ? FontWeight.w700 : FontWeight.w500,
            color: header ? VibColors.textLight : VibColors.textDark,
            letterSpacing: header ? 0.3 : 0,
          ),
        ),
      );
}

class _RoleCell extends StatelessWidget {
  const _RoleCell({required this.label, this.header = false});
  final String label;
  final bool header;

  @override
  Widget build(BuildContext context) => Container(
        width: 90,
        height: 40,
        color: header ? VibColors.bg : VibColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: header ? VibColors.textLight : VibColors.textMid,
            letterSpacing: 0.3,
          ),
        ),
      );
}

class _WeekCell extends StatelessWidget {
  const _WeekCell({required this.label, this.header = false});
  final String label;
  final bool header;

  @override
  Widget build(BuildContext context) => Container(
        width: 52,
        height: 40,
        color: VibColors.bg,
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: VibColors.textLight,
          ),
        ),
      );
}

// ── Heat Cell ─────────────────────────────────────────────────────────────────

class _HeatCell extends StatelessWidget {
  const _HeatCell({required this.value, required this.onTap});
  final int value;
  final VoidCallback onTap;

  Color get _bg {
    if (value == 0) return const Color(0xFFF5F7FA);
    if (value < 40) return const Color(0xFFE8F5E9); // available green
    if (value <= 80) return const Color(0xFFFFF9C4); // normal yellow
    if (value <= 100) return const Color(0xFFFFE0B2); // high orange
    return const Color(0xFFFFCDD2); // over red
  }

  Color get _text {
    if (value == 0) return VibColors.textLight;
    if (value < 40) return const Color(0xFF2E7D32);
    if (value <= 80) return const Color(0xFFF57F17);
    if (value <= 100) return const Color(0xFFE65100);
    return const Color(0xFFB71C1C);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: VibRadius.sm,
        ),
        alignment: Alignment.center,
        child: Text(
          value == 0 ? '—' : '$value%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _text,
          ),
        ),
      ),
    );
  }
}
