import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/models/user.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/top_bar.dart';
import '../../shared/widgets/vib_button.dart';
import 'auth_provider.dart';

// ── User Management Screen ────────────────────────────────────────────────────

class UserMgmtScreen extends ConsumerWidget {
  const UserMgmtScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: TopBar(
        title: 'User Management',
        actions: [
          VibButton(
            label: 'Add User',
            icon: Icons.person_add_outlined,
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (users) => _UserTable(users: users, ref: ref),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddUserDialog(onSaved: () => ref.invalidate(usersProvider)),
    );
  }
}

// ── User Table ────────────────────────────────────────────────────────────────

class _UserTable extends StatelessWidget {
  const _UserTable({required this.users, required this.ref});
  final List<User> users;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: VibColors.surface,
          borderRadius: VibRadius.md,
          border: Border.all(color: VibColors.border),
          boxShadow: VibShadow.sm,
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(VibColors.bg),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: users.map((u) => _userRow(context, u)).toList(),
        ),
      ),
    );
  }

  DataRow _userRow(BuildContext context, User u) => DataRow(cells: [
        DataCell(Text(u.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(u.email)),
        DataCell(_RoleBadge(role: u.role)),
        DataCell(_StatusBadge(active: u.isActive)),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 16),
              onPressed: () => _showEditDialog(context, u),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(
                u.isActive ? Icons.block : Icons.check_circle_outline,
                size: 16,
                color: u.isActive ? VibColors.danger : VibColors.teal,
              ),
              onPressed: () => _toggleActive(context, u),
              tooltip: u.isActive ? 'Deactivate' : 'Activate',
            ),
          ],
        )),
      ]);

  void _showEditDialog(BuildContext context, User u) {
    showDialog(
      context: context,
      builder: (_) => _AddUserDialog(
        user: u,
        onSaved: () => ref.invalidate(usersProvider),
      ),
    );
  }

  Future<void> _toggleActive(BuildContext context, User u) async {
    try {
      await ApiClient.instance.dio.patch('/admin/users/${u.id}', data: {
        'is_active': !u.isActive,
      });
      ref.invalidate(usersProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// ── Add/Edit Dialog ───────────────────────────────────────────────────────────

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog({this.user, required this.onSaved});
  final User? user;
  final VoidCallback onSaved;

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _form = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.user?.fullName);
  late final _emailCtrl = TextEditingController(text: widget.user?.email);
  final _passCtrl = TextEditingController();
  late String _role = widget.user?.role ?? 'member';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      if (widget.user == null) {
        await ApiClient.instance.dio.post('/admin/users', data: {
          'full_name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'password': _passCtrl.text,
          'role': _role,
        });
      } else {
        await ApiClient.instance.dio.patch('/admin/users/${widget.user!.id}', data: {
          'full_name': _nameCtrl.text.trim(),
          'role': _role,
        });
      }
      widget.onSaved();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? 'Add User' : 'Edit User'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: widget.user == null,
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Valid email required' : null,
              ),
              if (widget.user == null) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) => v == null || v.length < 6
                      ? 'Min 6 characters'
                      : null,
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['admin', 'pm', 'member', 'viewer']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        VibButton(
          label: widget.user == null ? 'Create' : 'Save',
          onPressed: _loading ? null : _submit,
          loading: _loading,
        ),
      ],
    );
  }
}

// ── Badges ────────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final String role;

  static const _colors = {
    'admin': Color(0xFF7B2CBF),
    'pm': VibColors.navy,
    'member': VibColors.teal,
    'viewer': VibColors.textLight,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[role] ?? VibColors.textMid;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: VibRadius.pill,
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (active ? VibColors.teal : VibColors.danger).withValues(alpha: 0.12),
        borderRadius: VibRadius.pill,
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: active ? VibColors.teal : VibColors.danger,
        ),
      ),
    );
  }
}
