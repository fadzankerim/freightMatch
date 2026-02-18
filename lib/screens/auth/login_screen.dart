import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onGoRegister;

  const LoginScreen({
    super.key,
    required this.onSuccess,
    required this.onGoRegister,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'alex@freightmatch.app');
  final _passCtrl  = TextEditingController(text: 'password123');
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
    if (mounted && ref.read(authProvider).isAuthenticated) {
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo row
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.darkTeal],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_shipping_rounded,
                          size: 22, color: AppColors.beige),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'FreightMatch',
                      style: GoogleFonts.syne(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                    ),
                  ],
                ).animate().fade().slideX(begin: -0.1, curve: Curves.easeOutCubic),

                const SizedBox(height: 44),

                Text('Welcome back',
                    style: Theme.of(context).textTheme.displaySmall)
                    .animate().fade(delay: 100.ms).slideY(begin: 0.2),

                const SizedBox(height: 6),
                Text('Sign in to find your next haul',
                    style: Theme.of(context).textTheme.bodyMedium)
                    .animate().fade(delay: 150.ms),

                const SizedBox(height: 36),

                CustomInput(
                  controller: _emailCtrl,
                  label: 'EMAIL',
                  hint: 'your@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Enter a valid email' : null,
                ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

                const SizedBox(height: 16),

                CustomInput(
                  controller: _passCtrl,
                  label: 'PASSWORD',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  suffix: GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 characters' : null,
                ).animate().fade(delay: 250.ms).slideY(begin: 0.1),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?'),
                  ),
                ),

                const SizedBox(height: 20),

                CustomButton(
                  label: 'Sign In',
                  onPressed: _submit,
                  isLoading: loading,
                  width: double.infinity,
                ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(
                      onPressed: widget.onGoRegister,
                      child: const Text('Sign Up'),
                    ),
                  ],
                ).animate().fade(delay: 380.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}