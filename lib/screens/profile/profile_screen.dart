import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user     = ref.watch(currentUserProvider);
    final earnings = ref.watch(earningsSummaryProvider);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero header ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.bgPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.darkTeal, AppColors.bgPrimary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Stack(
                        children: [
                          _Avatar(user: user, size: 72),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.bgPrimary, width: 2),
                              ),
                              child: const Icon(Icons.edit,
                                  size: 11, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(user.name,
                          style: GoogleFonts.syne(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      Text(user.userType.label,
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats ───────────────────────────────────────────────
                  Row(
                    children: [
                      _StatBox(
                          value: user.rating.toStringAsFixed(1),
                          label: 'Rating',
                          icon: Icons.star_rounded,
                          color: AppColors.warning),
                      _StatBox(
                          value: '${user.totalDeliveries}',
                          label: 'Deliveries',
                          icon: Icons.local_shipping_rounded,
                          color: AppColors.primary),
                      _StatBox(
                          value: '${user.responseRate.toInt()}%',
                          label: 'Response',
                          icon: Icons.speed_rounded,
                          color: AppColors.success),
                    ],
                  ).animate().fade().slideY(begin: 0.1),
                  const SizedBox(height: 18),

                  // ── Verification ────────────────────────────────────────
                  _SectionCard(
                    title: 'Verification',
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        _VerifChip('Email',   user.verification.email),
                        _VerifChip('Phone',   user.verification.phone),
                        _VerifChip('ID',      user.verification.identity),
                        _VerifChip('Insurance', user.verification.insurance),
                        _VerifChip('License', user.verification.driverLicense),
                      ],
                    ),
                  ).animate().fade(delay: 80.ms),
                  const SizedBox(height: 14),

                  // ── Earnings ────────────────────────────────────────────
                  if (user.userType != UserType.shipper) ...[
                    _SectionCard(
                      title: 'Earnings',
                      trailing: TextButton(
                          onPressed: () {},
                          child: const Text('See all')),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '€${earnings.total.toStringAsFixed(0)}',
                                style: GoogleFonts.syne(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary),
                              ),
                              Text('Total earnings',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '€${earnings.thisMonth.toStringAsFixed(0)}',
                                style: GoogleFonts.syne(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success),
                              ),
                              Text('This month',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 120.ms),
                    const SizedBox(height: 14),
                  ],

                  // ── Vehicles ────────────────────────────────────────────
                  if (user.vehicles.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('My Vehicles',
                            style:
                                Theme.of(context).textTheme.titleMedium),
                        TextButton(
                            onPressed: () {},
                            child: const Text('Add')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...user.vehicles.asMap().entries.map(
                          (e) => _VehicleRow(vehicle: e.value)
                              .animate()
                              .fade(
                                  delay: Duration(
                                      milliseconds: 160 + e.key * 60)),
                        ),
                    const SizedBox(height: 14),
                  ],

                  // ── Menu items ──────────────────────────────────────────
                  ...[
                    (Icons.person_outline, 'Edit Profile', false),
                    (Icons.directions_car_outlined, 'My Vehicles', false),
                    (Icons.payment_outlined, 'Payment Methods', false),
                    (Icons.description_outlined, 'Documents', false),
                    (Icons.star_outline_rounded, 'Reviews', false),
                    (Icons.settings_outlined, 'Settings', false),
                    (Icons.help_outline_rounded, 'Help & Support', false),
                    (Icons.logout_rounded, 'Logout', true),
                  ]
                      .asMap()
                      .entries
                      .map(
                        (e) {
                          final (icon, label, destructive) = e.value;
                          return _MenuItem(
                            icon: icon,
                            label: label,
                            isDestructive: destructive,
                            onTap: destructive
                                ? () async {
                                    await ref
                                        .read(authProvider.notifier)
                                        .logout();
                                    onLogout();
                                  }
                                : () {},
                          ).animate().fade(
                              delay: Duration(
                                  milliseconds: 220 + e.key * 30));
                        },
                      )
                      .toList(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final AppUser user;
  final double size;
  const _Avatar({required this.user, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkTeal,
        border: Border.all(color: AppColors.border, width: 2),
        image: user.avatarUrl != null
            ? DecorationImage(
                image: NetworkImage(user.avatarUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: user.avatarUrl == null
          ? Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: GoogleFonts.syne(
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
            )
          : null,
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(value,
                style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard(
      {required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.titleMedium),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _VerifChip extends StatelessWidget {
  final String label;
  final bool verified;
  const _VerifChip(this.label, this.verified);

  @override
  Widget build(BuildContext context) {
    final c = verified ? AppColors.success : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: verified ? AppColors.success.withOpacity(0.1) : AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
            color: verified
                ? AppColors.success.withOpacity(0.4)
                : AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            size: 12,
            color: c,
          ),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 12, fontWeight: FontWeight.w500, color: c)),
        ],
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleRow({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.local_shipping_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.displayName,
                    style: Theme.of(context).textTheme.titleSmall),
                Text(
                  '${vehicle.type.label} · ${vehicle.licensePlate} · ${vehicle.weightCapacity.toInt()} kg',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (vehicle.insuranceVerified)
            const Icon(Icons.verified_rounded,
                color: AppColors.success, size: 18),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.isDestructive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = isDestructive ? AppColors.error : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDestructive
                        ? AppColors.error
                        : AppColors.textPrimary,
                  )),
            ),
            Icon(Icons.chevron_right, size: 18, color: c),
          ],
        ),
      ),
    );
  }
}
