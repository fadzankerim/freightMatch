import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/listing.dart';
import '../../providers/listings_provider.dart';
import '../design/app_atoms.dart';
import '../common/loading_spinner.dart';

class ListingCard extends ConsumerWidget {
  final Listing listing;
  final VoidCallback onTap;
  final int index;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(isSavedProvider(listing.id));

    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: index * 60), duration: 380.ms),
        SlideEffect(
          delay: Duration(milliseconds: index * 60),
          duration: 380.ms,
          begin: const Offset(0, 0.07),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Photo ──────────────────────────────────────────────────────
              if (listing.load.photoUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        listing.load.photoUrls.first,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _photoPlaceholder(),
                      ),
                      // price badge
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _PriceBadge(listing.priceDisplay),
                      ),
                      if (listing.priceNegotiable)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: _NegotiableBadge(),
                        ),
                    ],
                  ),
                )
              else
                _noPhotoBanner(listing.priceDisplay, listing.priceNegotiable),

              // ── Body ───────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // route
                    RouteCityRow(from: listing.pickup.city, to: listing.delivery.city),
                    const SizedBox(height: 10),

                    // stats chips
                    Row(
                      children: [
                        MetaChip(icon: Icons.straighten_rounded, label: listing.distanceDisplay),
                        const SizedBox(width: 6),
                        MetaChip(icon: Icons.timer_outlined, label: listing.durationDisplay),
                        const SizedBox(width: 6),
                        MetaChip(icon: Icons.scale_outlined, label: listing.load.weightDisplay),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // vehicle + date
                    Row(
                      children: [
                        VehicleTypeChip(type: listing.requiredVehicleType),
                        const Spacer(),
                        Icon(Icons.calendar_today_outlined,
                            size: 11, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM').format(listing.pickupDate),
                          style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // user row
                    Row(
                      children: [
                        if (listing.user != null) ...[
                          AppAvatar(
                              imageUrl: listing.user!.avatarUrl,
                              name: listing.user!.name,
                              size: 28),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listing.user!.name,
                                    style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary)),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        size: 11, color: AppColors.warning),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${listing.user!.rating.toStringAsFixed(1)} · ${listing.user!.totalDeliveries} jobs',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ] else
                          const Spacer(),
                        GestureDetector(
                          onTap: () => ref
                              .read(savedProvider.notifier)
                              .toggle(listing.id),
                          child: AnimatedContainer(
                            duration: 180.ms,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: saved
                                  ? AppColors.primary.withOpacity(0.15)
                                  : AppColors.bgElevated,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              saved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_outline_rounded,
                              size: 18,
                              color: saved
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoPlaceholder() => Container(
        height: 140,
        color: AppColors.bgElevated,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              color: AppColors.textMuted),
        ),
      );

  Widget _noPhotoBanner(String price, bool negotiable) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined,
              color: AppColors.primary, size: 22),
          const Spacer(),
          _PriceBadge(price),
          if (negotiable) ...[
            const SizedBox(width: 8),
            _NegotiableBadge(),
          ],
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _PriceBadge extends StatelessWidget {
  final String label;
  const _PriceBadge(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary.withOpacity(0.85),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: GoogleFonts.syne(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      );
}

class _NegotiableBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.success.withOpacity(0.4)),
        ),
        child: Text(
          'Negotiable',
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
      );
}
