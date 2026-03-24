import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ── VibButton ─────────────────────────────────────────────────────────────────

enum VibButtonVariant { primary, secondary, danger, ghost }

class VibButton extends StatelessWidget {
  const VibButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = VibButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.small = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final VibButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final h = small ? 32.0 : 40.0;
    final fontSize = small ? 12.0 : 13.0;

    return SizedBox(
      height: h,
      child: switch (variant) {
        VibButtonVariant.primary => _GradientButton(
            label: label,
            icon: icon,
            loading: loading,
            fontSize: fontSize,
            onPressed: onPressed,
          ),
        VibButtonVariant.secondary => OutlinedButton.icon(
            icon: icon != null
                ? Icon(icon, size: small ? 14 : 16)
                : const SizedBox.shrink(),
            label: loading
                ? _Spinner(color: VibColors.textMid)
                : Text(label),
            onPressed: loading ? null : onPressed,
          ),
        VibButtonVariant.danger => ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: VibColors.danger,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: EdgeInsets.symmetric(
                  horizontal: small ? 14 : 20, vertical: 0),
            ),
            icon: icon != null
                ? Icon(icon, size: small ? 14 : 16)
                : const SizedBox.shrink(),
            label: loading
                ? _Spinner(color: Colors.white)
                : Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: fontSize)),
            onPressed: loading ? null : onPressed,
          ),
        VibButtonVariant.ghost => TextButton.icon(
            icon: icon != null
                ? Icon(icon, size: small ? 14 : 16)
                : const SizedBox.shrink(),
            label: loading ? _Spinner(color: VibColors.navy) : Text(label),
            onPressed: loading ? null : onPressed,
          ),
      },
    );
  }
}

// ── Gradient primary button ───────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
    required this.fontSize,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : VibColors.gradBrand,
        color: onPressed == null ? VibColors.border : null,
        borderRadius: VibRadius.pill,
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: const StadiumBorder(),
          padding:
              EdgeInsets.symmetric(horizontal: fontSize < 13 ? 14 : 20, vertical: 0),
        ),
        icon: loading
            ? _Spinner(color: VibColors.navyDark)
            : (icon != null ? Icon(icon, size: 16) : const SizedBox.shrink()),
        label: loading
            ? const SizedBox.shrink()
            : Text(
                label,
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: fontSize),
              ),
        onPressed: loading ? null : onPressed,
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
}
