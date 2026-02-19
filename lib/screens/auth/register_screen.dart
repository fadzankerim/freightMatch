import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_input.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onGoLogin;

  const RegisterScreen({
    super.key,
    required this.onSuccess,
    required this.onGoLogin,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _homeCityCtrl = TextEditingController(text: 'Sarajevo');
  final _homeCountryCtrl =
      TextEditingController(text: 'Bosnia and Herzegovina');
  UserType _type    = UserType.hauler;
  bool _obscure     = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _homeCityCtrl.dispose();
    _homeCountryCtrl.dispose();
    super.dispose();
  }

  Future<UserLocation> _resolveHomeLocation() async {
    final city = _homeCityCtrl.text.trim();
    final country = _homeCountryCtrl.text.trim();
    if (city.isEmpty || country.isEmpty) {
      return const UserLocation(
        city: 'Sarajevo',
        country: 'Bosnia and Herzegovina',
        lat: 43.8563,
        lng: 18.4131,
      );
    }
    try {
      final places = await locationFromAddress('$city, $country');
      if (places.isNotEmpty) {
        return UserLocation(
          city: city,
          country: country,
          lat: places.first.latitude,
          lng: places.first.longitude,
        );
      }
    } catch (_) {}

    return UserLocation(
      city: city,
      country: country,
      lat: 43.8563,
      lng: 18.4131,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final homeLocation = await _resolveHomeLocation();
    await ref.read(authProvider.notifier).register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          password: _passCtrl.text,
          userType: _type,
          homeLocation: homeLocation,
        );
    if (mounted && ref.read(authProvider).isAuthenticated) {
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onGoLogin,
        ),
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Account type selector ─────────────────────────────────
                Text('I want to…',
                    style: Theme.of(context).textTheme.titleLarge)
                    .animate().fade().slideY(begin: 0.1),
                const SizedBox(height: 12),

                Row(
                  children: UserType.values.map((t) {
                    final selected = _type == t;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _type = t),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primarySurface
                                : AppColors.bgCard,
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                t == UserType.hauler
                                    ? Icons.local_shipping_rounded
                                    : t == UserType.shipper
                                        ? Icons.inventory_2_outlined
                                        : Icons.swap_horiz_rounded,
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                size: 22,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t == UserType.hauler
                                    ? 'Haul'
                                    : t == UserType.shipper
                                        ? 'Ship'
                                        : 'Both',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fade(delay: 80.ms),

                const SizedBox(height: 28),

                CustomInput(
                  controller: _nameCtrl,
                  label: 'FULL NAME',
                  hint: 'John Hauler',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || v.length < 2 ? 'Enter your name' : null,
                ).animate().fade(delay: 120.ms).slideY(begin: 0.1),
                const SizedBox(height: 14),

                CustomInput(
                  controller: _emailCtrl,
                  label: 'EMAIL',
                  hint: 'your@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Enter a valid email' : null,
                ).animate().fade(delay: 160.ms).slideY(begin: 0.1),
                const SizedBox(height: 14),

                CustomInput(
                  controller: _phoneCtrl,
                  label: 'PHONE NUMBER',
                  hint: '+387 61 234 567',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || v.length < 8 ? 'Enter a valid number' : null,
                ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: CustomInput(
                        controller: _homeCityCtrl,
                        label: 'HOME CITY',
                        hint: 'Sarajevo',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomInput(
                        controller: _homeCountryCtrl,
                        label: 'HOME COUNTRY',
                        hint: 'Bosnia and Herzegovina',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ).animate().fade(delay: 220.ms).slideY(begin: 0.1),
                const SizedBox(height: 14),

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
                ).animate().fade(delay: 240.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                CustomButton(
                  label: 'Create Account',
                  onPressed: _submit,
                  isLoading: loading,
                  width: double.infinity,
                ).animate().fade(delay: 280.ms).slideY(begin: 0.1),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(
                      onPressed: widget.onGoLogin,
                      child: const Text('Sign In'),
                    ),
                  ],
                ).animate().fade(delay: 320.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
