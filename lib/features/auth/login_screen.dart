import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/vib_button.dart';
import '../dashboard/projects_provider.dart';
import 'auth_provider.dart';

// ── Login Screen ──────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _error = null);

    await ref.read(authStateProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );

    if (!mounted) return;
    final authState = ref.read(authStateProvider);
    authState.whenOrNull(
      data: (user) {
        if (user != null) ref.invalidate(projectsProvider);
      },
      error: (e, _) => setState(
        () => _error = e.toString().replaceAll('Exception: ', ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      backgroundColor: VibColors.bg,
      body: Row(
        children: [
          // Left — brand panel
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(gradient: VibColors.gradNavy),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: VibColors.gradBrand,
                      borderRadius: VibRadius.lg,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'VB',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: VibColors.navyDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'VIB Project\nManagement',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Internal tool for IT project teams',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right — login form
          Expanded(
            flex: 6,
            child: Center(
              child: SizedBox(
                width: 380,
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Sign in',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Use your VIB account credentials',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined, size: 18),
                        ),
                        validator: (v) =>
                            v == null || !v.contains('@') ? 'Valid email required' : null,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.length < 4 ? 'Password required' : null,
                      ),
                      const SizedBox(height: 8),

                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: VibColors.danger.withValues(alpha: 0.08),
                            borderRadius: VibRadius.sm,
                            border: Border.all(
                                color: VibColors.danger.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 16, color: VibColors.danger),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: VibColors.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: VibButton(
                          label: 'Sign in',
                          onPressed: loading ? null : _submit,
                          loading: loading,
                          icon: Icons.arrow_forward,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
