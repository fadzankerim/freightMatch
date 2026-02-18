import 'package:flutter/material.dart';
import 'package:freight_match/models/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/listing.dart';

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

class ListingCardHorizontal extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final int index;

  const ListingCardHorizontal({
    super.key,
    required this.listing,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: 200 + index * 60), duration: 380.ms),
        SlideEffect(
          delay: Duration(milliseconds: 200 + index * 60),
          duration: 380.ms,
          begin: const Offset(0.1, 0),
          end: Offset.zero,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 210,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thumbnail ───────────────────────────────────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg)),
                child: listing.load.photoUrls.isNotEmpty
                    ? Image.network(
                        listing.load.photoUrls.first,
                        height: 80,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),

              // ── Info ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // route
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.pickup.city,
                            style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.arrow_forward,
                              size: 11, color: AppColors.primary),
                        ),
                        Expanded(
                          child: Text(
                            listing.delivery.city,
                            style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // price + distance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          listing.priceDisplay,
                          style: GoogleFonts.syne(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                        ),
                        Text(
                          listing.distanceDisplay,
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _VehicleBadge(listing.requiredVehicleType),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 80,
        color: AppColors.bgElevated,
        child: Center(
          child: Icon(Icons.local_shipping_outlined,
              color: AppColors.primary.withOpacity(0.4), size: 26),
        ),
      );
}