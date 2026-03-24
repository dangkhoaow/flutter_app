import 'package:flutter/material.dart';
import 'sidebar.dart';

// ── AppShell ──────────────────────────────────────────────────────────────────
// Wraps every authenticated route: navy sidebar + content area

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
