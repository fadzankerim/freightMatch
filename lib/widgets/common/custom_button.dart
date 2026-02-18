import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

enum ButtonVariant { primary, outlined, ghost }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final bool isSmall;
  final IconData? icon;
  final double? width;
  final Color? color;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.isSmall = false,
    this.icon,
    this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg    = color ?? AppColors.primary;
    final hPad  = isSmall ? 14.0 : 20.0;
    final vPad  = isSmall ? 10.0 : 14.0;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );

    final child = _child();

    return SizedBox(
      width: width,
      child: switch (variant) {
        ButtonVariant.primary => ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: AppColors.textPrimary,
              disabledBackgroundColor: AppColors.border,
              disabledForegroundColor: AppColors.textMuted,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              shape: shape,
            ),
            child: child,
          ),
        ButtonVariant.outlined => OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: bg,
              side: BorderSide(color: bg, width: 1.5),
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              shape: shape,
            ),
            child: child,
          ),
        ButtonVariant.ghost => TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: bg,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              shape: shape,
            ),
            child: child,
          ),
      },
    );
  }

  Widget _child() {
    if (isLoading) {
      return SizedBox(
        height: isSmall ? 16 : 20,
        width: isSmall ? 16 : 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: variant == ButtonVariant.primary
              ? AppColors.textPrimary
              : AppColors.primary,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: isSmall ? 14 : 18),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: isSmall ? 13 : 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}