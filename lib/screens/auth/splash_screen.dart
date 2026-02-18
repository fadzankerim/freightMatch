import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    Future.delayed(AppConstants.splashDelay, widget.onComplete);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.darkTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.local_shipping_rounded,
                  size: 46, color: AppColors.beige),
            )
                .animate(controller: _ctrl)
                .scale(begin: const Offset(0.4, 0.4), curve: Curves.elasticOut)
                .fade(),

            const SizedBox(height: 24),

            Text(
              AppConstants.appName,
              style: GoogleFonts.syne(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            )
                .animate(controller: _ctrl)
                .fade(delay: 400.ms)
                .slideY(begin: 0.3, curve: Curves.easeOutCubic),

            const SizedBox(height: 8),

            Text(
              AppConstants.appTagline,
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: AppColors.textMuted),
            )
                .animate(controller: _ctrl)
                .fade(delay: 650.ms),

            const SizedBox(height: 60),

            // Loading dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(
                      delay: Duration(milliseconds: 800 + i * 150),
                      duration: 600.ms,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}