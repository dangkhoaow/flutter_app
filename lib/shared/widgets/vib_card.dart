import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ── VibCard ───────────────────────────────────────────────────────────────────

class VibCard extends StatelessWidget {
  const VibCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.accentColor,
    this.shadow = VibShadow.sm,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? accentColor;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VibColors.surface,
        borderRadius: VibRadius.md,
        boxShadow: shadow,
        border: accentColor != null
            ? Border(left: BorderSide(color: accentColor!, width: 3))
            : const Border.fromBorderSide(
                BorderSide(color: VibColors.border),
              ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: VibRadius.md,
        child: InkWell(
          borderRadius: VibRadius.md,
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ── KPI Card ──────────────────────────────────────────────────────────────────

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: VibRadius.lg,
        boxShadow: VibShadow.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.9)),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
