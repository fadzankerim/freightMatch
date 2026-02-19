import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/listing.dart';
import '../design/app_atoms.dart';

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
                    RouteCityRow(
                      from: listing.pickup.city,
                      to: listing.delivery.city,
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
                    VehicleTypeChip(type: listing.requiredVehicleType),
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
