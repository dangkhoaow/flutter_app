import 'package:flutter/material.dart';
import '../../core/models/project.dart';
import '../../core/theme/app_theme.dart';

// ── Project Card ──────────────────────────────────────────────────────────────

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap});

  final Project project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = _hexToColor(project.color);

    return Material(
      color: VibColors.surface,
      borderRadius: VibRadius.md,
      child: InkWell(
        borderRadius: VibRadius.md,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: VibRadius.md,
            border: Border.all(color: VibColors.border),
            boxShadow: VibShadow.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: VibColors.navyDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(status: project.status),
                      ],
                    ),
                    if (project.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        project.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progress',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: VibColors.textLight),
                                  ),
                                  Text(
                                    '${project.completionPct}%',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: VibColors.textDark),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: VibRadius.pill,
                                child: LinearProgressIndicator(
                                  value: project.completionPct / 100,
                                  backgroundColor: VibColors.border,
                                  valueColor: AlwaysStoppedAnimation(
                                    accentColor,
                                  ),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.people_outline,
                            size: 13, color: VibColors.textLight),
                        const SizedBox(width: 4),
                        Text(
                          '${project.memberCount} members',
                          style: const TextStyle(
                              fontSize: 11, color: VibColors.textLight),
                        ),
                        const Spacer(),
                        if (project.isBehindSchedule)
                          _BehindBadge()
                        else
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  size: 12, color: VibColors.textLight),
                              const SizedBox(width: 4),
                              Text(
                                _fmtDate(project.endDate),
                                style: const TextStyle(
                                    fontSize: 11, color: VibColors.textLight),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  static const _map = {
    'active': (Color(0xFF2A9D8F), 'Active'),
    'on_hold': (Color(0xFF999999), 'On Hold'),
    'completed': (Color(0xFF1A2B5F), 'Done'),
    'archived': (Color(0xFFCCCCCC), 'Archived'),
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
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _BehindBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: VibColors.danger.withValues(alpha: 0.1),
        borderRadius: VibRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 10, color: VibColors.danger),
          const SizedBox(width: 3),
          const Text(
            'Behind',
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: VibColors.danger),
          ),
        ],
      ),
    );
  }
}
