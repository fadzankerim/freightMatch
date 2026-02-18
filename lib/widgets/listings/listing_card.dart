import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/listing.dart';
import '../../models/user.dart';
import '../../providers/listings_provider.dart';
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
                    _RouteRow(from: listing.pickup.city, to: listing.delivery.city),
                    const SizedBox(height: 10),

                    // stats chips
                    Row(
                      children: [
                        _StatChip(Icons.straighten_rounded, listing.distanceDisplay),
                        const SizedBox(width: 6),
                        _StatChip(Icons.timer_outlined, listing.durationDisplay),
                        const SizedBox(width: 6),
                        _StatChip(Icons.scale_outlined, listing.load.weightDisplay),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // vehicle + date
                    Row(
                      children: [
                        _VehicleBadge(listing.requiredVehicleType),
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

class _RouteRow extends StatelessWidget {
  final String from;
  final String to;
  const _RouteRow({required this.from, required this.to});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              from,
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle)),
                Container(width: 28, height: 1, color: AppColors.primary),
                const Icon(Icons.arrow_forward,
                    size: 13, color: AppColors.primary),
              ],
            ),
          ),
          Expanded(
            child: Text(
              to,
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
}

class _VehicleBadge extends StatelessWidget {
  final VehicleType type;
  const _VehicleBadge(this.type);

  Color get _color {
    switch (type) {
      case VehicleType.van:        return AppColors.van;
      case VehicleType.pickup:     return AppColors.pickup;
      case VehicleType.smallTruck: return AppColors.smallTruck;
      case VehicleType.largeTruck: return AppColors.largeTruck;
      case VehicleType.flatbed:    return AppColors.flatbed;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: _color.withOpacity(0.4)),
        ),
        child: Text(
          type.label,
          style: GoogleFonts.dmSans(
              fontSize: 11, fontWeight: FontWeight.w600, color: _color),
        ),
      );
}