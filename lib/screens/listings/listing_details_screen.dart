import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/listing.dart';
import '../../providers/listings_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/design/app_atoms.dart';

class ListingDetailsScreen extends ConsumerWidget {
  final Listing listing;
  const ListingDetailsScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(isSavedProvider(listing.id));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bgCard.withOpacity(0.85),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => ref.read(savedProvider.notifier).toggle(listing.id),
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 8, 12, 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgCard.withOpacity(0.85),
                shape: BoxShape.circle,
              ),
              child: Icon(
                saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                color: saved ? AppColors.primary : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Photo header ──────────────────────────────────────────
                  _PhotoHeader(listing: listing),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Price row ───────────────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(listing.priceDisplay,
                                style: GoogleFonts.syne(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                )),
                            if (listing.priceNegotiable)
                              Container(
                                margin: const EdgeInsets.only(left: 10, top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                ),
                                child: Text('Negotiable',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.success)),
                              ),
                            const Spacer(),
                            VehicleTypeChip(type: listing.requiredVehicleType),
                          ],
                        ).animate().fade().slideY(begin: 0.1),
                        const SizedBox(height: 20),

                        // ── Route card ─────────────────────────────────────
                        CustomCard(
                          child: Column(
                            children: [
                              _RouteStop(
                                icon: Icons.radio_button_checked,
                                color: AppColors.success,
                                label: 'PICKUP',
                                address: listing.pickup.fullAddress,
                                date: listing.pickupDate,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 9),
                                child: Column(
                                  children: List.generate(
                                    3,
                                    (_) => Container(
                                      width: 2, height: 6,
                                      margin: const EdgeInsets.symmetric(vertical: 2),
                                      color: AppColors.border,
                                    ),
                                  ),
                                ),
                              ),
                              _RouteStop(
                                icon: Icons.location_on,
                                color: AppColors.error,
                                label: 'DELIVERY',
                                address: listing.delivery.fullAddress,
                                date: listing.deliveryDate,
                              ),
                            ],
                          ),
                        ).animate().fade(delay: 80.ms),
                        const SizedBox(height: 12),

                        // ── Stats grid ─────────────────────────────────────
                        Row(
                          children: [
                            Expanded(child: _StatCard(icon: Icons.straighten_rounded,
                                label: 'Distance', value: listing.distanceDisplay)),
                            const SizedBox(width: 8),
                            Expanded(child: _StatCard(icon: Icons.timer_outlined,
                                label: 'Est. Time', value: listing.durationDisplay)),
                            const SizedBox(width: 8),
                            Expanded(child: _StatCard(icon: Icons.scale_outlined,
                                label: 'Weight', value: listing.load.weightDisplay)),
                          ],
                        ).animate().fade(delay: 120.ms),
                        const SizedBox(height: 20),

                        // ── Load description ───────────────────────────────
                        Text('Load Details',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.load.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.5),
                              ),
                              if (listing.load.isFragile ||
                                  listing.load.specialRequirements.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    if (listing.load.isFragile)
                                      _Tag('⚠️ Fragile', AppColors.warning),
                                    if (listing.load.needsRefrigeration)
                                      _Tag('❄️ Refrigerated', AppColors.info),
                                    ...listing.load.specialRequirements
                                        .map((r) => _Tag(r, AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ).animate().fade(delay: 160.ms),
                        const SizedBox(height: 20),

                        // ── Poster card ────────────────────────────────────
                        if (listing.user != null) ...[
                          Text('Posted by',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                          CustomCard(
                            child: Row(
                              children: [
                                _UserAvatar(user: listing.user!),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(listing.user!.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      const SizedBox(height: 3),
                                      Row(children: [
                                        const Icon(Icons.star_rounded,
                                            size: 13, color: AppColors.warning),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${listing.user!.rating} · '
                                          '${listing.user!.totalDeliveries} jobs · '
                                          '${listing.user!.responseRate.toInt()}% response',
                                          style: GoogleFonts.dmSans(
                                              fontSize: 12,
                                              color: AppColors.textMuted),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                                if (listing.user!.verification.identity)
                                  const Icon(Icons.verified_rounded,
                                      color: AppColors.info, size: 20),
                              ],
                            ),
                          ).animate().fade(delay: 200.ms),
                        ],

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom action bar ───────────────────────────────────────────
          _ActionBar(listing: listing),
        ],
      ),
    );
  }
}

// ── Photo header ────────────────────────────────────────────────────────────
class _PhotoHeader extends StatefulWidget {
  final Listing listing;
  const _PhotoHeader({required this.listing});

  @override
  State<_PhotoHeader> createState() => _PhotoHeaderState();
}

class _PhotoHeaderState extends State<_PhotoHeader> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final photos = widget.listing.load.photoUrls;
    return SizedBox(
      height: 270,
      child: Stack(
        children: [
          photos.isNotEmpty
              ? PageView.builder(
                  itemCount: photos.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => Image.network(
                    photos[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  ),
                )
              : _placeholder(),

          // page dots
          if (photos.length > 1)
            Positioned(
              bottom: 12, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  photos.length,
                  (i) => AnimatedContainer(
                    duration: 200.ms,
                    width: _page == i ? 16 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: _page == i
                          ? AppColors.primary
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.bgElevated,
        child: const Center(
          child: Icon(Icons.local_shipping_outlined,
              color: AppColors.textMuted, size: 48),
        ),
      );
}

// ── Bottom action bar ────────────────────────────────────────────────────────
class _ActionBar extends ConsumerWidget {
  final Listing listing;
  const _ActionBar({required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: ActionHierarchy(
        primaryLabel: 'Accept Load · ${listing.priceDisplay}',
        onPrimary: () => _showConfirmSheet(context, ref),
        secondaryLabel: 'Chat',
        onSecondary: () {},
        tertiaryLabel: 'Close',
        onTertiary: () => Navigator.maybePop(context),
      ),
    );
  }

  void _showConfirmSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Confirm Load',
                style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('${listing.pickup.city} → ${listing.delivery.city}',
                style: Theme.of(ctx).textTheme.bodyLarge),
            const SizedBox(height: 4),
            Text(listing.priceDisplay,
                style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
            const SizedBox(height: 24),
            ActionHierarchy(
              primaryLabel: 'Confirm & Accept',
              onPrimary: () {
                ref
                    .read(bookingsProvider.notifier)
                    .createBooking(listing, listing.price);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 Load accepted! Check your bookings.'),
                  ),
                );
              },
              secondaryLabel: 'Make an Offer',
              onSecondary: () => Navigator.pop(ctx),
              tertiaryLabel: 'Cancel',
              onTertiary: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Route stop row ───────────────────────────────────────────────────────────
class _RouteStop extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String address;
  final DateTime date;

  const _RouteStop({
    required this.icon,
    required this.color,
    required this.label,
    required this.address,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(address,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(DateFormat('EEE, dd MMM · HH:mm').format(date),
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.syne(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final dynamic user;
  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkTeal,
        border: Border.all(color: AppColors.border, width: 1.5),
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
            )
          : null,
    );
  }
}
