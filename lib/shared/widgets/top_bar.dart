import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/auth_provider.dart';

// ── TopBar ────────────────────────────────────────────────────────────────────

class TopBar extends ConsumerWidget implements PreferredSizeWidget {
  const TopBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;

    return Container(
      height: preferredSize.height,
      decoration: const BoxDecoration(
        color: VibColors.surface,
        border: Border(bottom: BorderSide(color: VibColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          if (actions != null) ...actions!,
          if (actions != null) const SizedBox(width: 12),
          _UserPill(user: user),
        ],
      ),
    );
  }
}

// ── UserPill ──────────────────────────────────────────────────────────────────

class _UserPill extends StatelessWidget {
  const _UserPill({this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: VibColors.bg,
        borderRadius: VibRadius.pill,
        border: Border.all(color: VibColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: VibColors.brand.withValues(alpha: 0.2),
            child: Text(
              user?.fullName.isNotEmpty == true
                  ? user!.fullName[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: VibColors.navyDark,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            user?.fullName ?? 'User',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: VibColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
