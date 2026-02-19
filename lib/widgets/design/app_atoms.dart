import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../models/user.dart';
import '../common/custom_button.dart';

class VehicleTypeChip extends StatelessWidget {
  final VehicleType type;

  const VehicleTypeChip({
    super.key,
    required this.type,
  });

  Color get _color {
    switch (type) {
      case VehicleType.van:
        return AppColors.van;
      case VehicleType.pickup:
        return AppColors.pickup;
      case VehicleType.smallTruck:
        return AppColors.smallTruck;
      case VehicleType.largeTruck:
        return AppColors.largeTruck;
      case VehicleType.flatbed:
        return AppColors.flatbed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        type.label,
        style: GoogleFonts.dmSans(
          fontSize: AppTypeScale.label,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class RouteCityRow extends StatelessWidget {
  final String from;
  final String to;

  const RouteCityRow({
    super.key,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            from,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
        ),
        Expanded(
          child: Text(
            to,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
          ),
        ),
      ],
    );
  }
}

class MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const MetaChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppTypeScale.label, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: AppTypeScale.label,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionHierarchy extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? tertiaryLabel;
  final VoidCallback? onTertiary;
  final bool loading;
  final bool fullPrimary;

  const ActionHierarchy({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.tertiaryLabel,
    this.onTertiary,
    this.loading = false,
    this.fullPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasSecondary = secondaryLabel != null && onSecondary != null;
    final primary = CustomButton(
      label: primaryLabel,
      onPressed: onPrimary,
      isLoading: loading,
      width: fullPrimary ? double.infinity : null,
    );

    final row = hasSecondary
        ? Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: secondaryLabel!,
                  onPressed: onSecondary,
                  variant: ButtonVariant.outlined,
                  width: double.infinity,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: primary),
            ],
          )
        : primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        if (tertiaryLabel != null && onTertiary != null) ...[
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: onTertiary,
            child: Text(tertiaryLabel!),
          ),
        ],
      ],
    );
  }
}
