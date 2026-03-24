import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';
import '../../features/auth/auth_provider.dart';

// ── Sidebar ───────────────────────────────────────────────────────────────────

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  static const _width = 220.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final user = ref.watch(authStateProvider).valueOrNull;

    return Container(
      width: _width,
      decoration: const BoxDecoration(
        gradient: VibColors.gradNavy,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Logo(),
          const SizedBox(height: 8),
          _NavItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            path: AppRoutes.dashboard,
            active: location == AppRoutes.dashboard,
          ),
          _NavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Resources',
            path: AppRoutes.resources,
            active: location == AppRoutes.resources,
          ),
          if (user?.isAdmin == true) ...[
            _SectionLabel('Admin'),
            _NavItem(
              icon: Icons.people_outline,
              label: 'Users',
              path: AppRoutes.users,
              active: location == AppRoutes.users,
            ),
          ],
          const Spacer(),
          _UserTile(user: user),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Logo ──────────────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: VibColors.gradBrand,
              borderRadius: VibRadius.sm,
            ),
            alignment: Alignment.center,
            child: const Text(
              'VB',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: VibColors.navyDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'VIB PM',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0x66FFFFFF),
            letterSpacing: 1.2,
          ),
        ),
      );
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.path,
    required this.active,
  });

  final IconData icon;
  final String label;
  final String path;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: active ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: VibRadius.md,
        child: InkWell(
          borderRadius: VibRadius.md,
          onTap: () => context.go(path),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: active ? VibColors.brand : Colors.white.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    color: active ? Colors.white : Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                if (active) ...[
                  const Spacer(),
                  Container(
                    width: 3,
                    height: 16,
                    decoration: BoxDecoration(
                      color: VibColors.brand,
                      borderRadius: VibRadius.pill,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── User Tile ─────────────────────────────────────────────────────────────────

class _UserTile extends ConsumerWidget {
  const _UserTile({this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: VibRadius.md,
        child: InkWell(
          borderRadius: VibRadius.md,
          onTap: () => ref.read(authStateProvider.notifier).logout(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: VibColors.brand.withValues(alpha: 0.3),
                  child: Text(
                    user?.fullName.isNotEmpty == true
                        ? user!.fullName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.role.toUpperCase() ?? '',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withValues(alpha: 0.5),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.logout, size: 14, color: Colors.white.withValues(alpha: 0.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
