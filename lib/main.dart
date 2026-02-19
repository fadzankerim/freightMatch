import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'config/theme.dart';
import 'models/listing.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/map_screen.dart';
import 'screens/listings/listing_details_screen.dart';
import 'screens/listings/create_listing_screen.dart';
import 'screens/bookings/bookings_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'widgets/common/loading_spinner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiStyle);
  runApp(const ProviderScope(child: FreightMatchApp()));
}

class FreightMatchApp extends StatelessWidget {
  const FreightMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreightMatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const _Root(),
    );
  }
}

// ── Root — decides splash → auth → main ───────────────────────────────────────
class _Root extends ConsumerStatefulWidget {
  const _Root();

  @override
  ConsumerState<_Root> createState() => _RootState();
}

class _RootState extends ConsumerState<_Root> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return SplashScreen(
        onComplete: () => setState(() => _splashDone = true),
      );
    }
    final auth = ref.watch(authProvider);
    if (!auth.isInitialized) {
      return const Scaffold(body: LoadingSpinner(message: 'Restoring session...'));
    }

    final authed = auth.isAuthenticated;
    return AnimatedSwitcher(
      duration: 300.ms,
      child: authed ? const _MainShell() : const _AuthFlow(),
    );
  }
}

// ── Auth flow ─────────────────────────────────────────────────────────────────
class _AuthFlow extends StatefulWidget {
  const _AuthFlow();

  @override
  State<_AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<_AuthFlow> {
  bool _register = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: 280.ms,
      child: _register
          ? RegisterScreen(
              key: const ValueKey('reg'),
              onSuccess: () {},
              onGoLogin: () => setState(() => _register = false),
            )
          : LoginScreen(
              key: const ValueKey('login'),
              onSuccess: () {},
              onGoRegister: () => setState(() => _register = true),
            ),
    );
  }
}

// ── Main shell — bottom nav + listing details overlay ─────────────────────────
class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _tab = 0;
  Listing? _detailListing; // non-null → slide ListingDetails on top

  void _openListing(Listing l) => setState(() => _detailListing = l);
  void _closeListing()        => setState(() => _detailListing = null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Tab body ────────────────────────────────────────────────────
          _TabBody(
            tab: _tab,
            onListingTap: _openListing,
            onCreateSuccess: () => setState(() => _tab = 0),
            onLogout: () => setState(() {
              _tab = 0;
              _detailListing = null;
            }),
          ),

          // ── Listing details slide-over ───────────────────────────────────
          if (_detailListing != null)
            Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _closeListing, // tap background closes
                child: Container(
                  color: Colors.transparent,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {}, // block tap-through
                      child: ListingDetailsScreen(listing: _detailListing!)
                          .animate()
                          .slideX(
                            begin: 1,
                            end: 0,
                            duration: 300.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      // Hide bottom nav when listing detail is open
      bottomNavigationBar: _detailListing != null
          ? null
          : _BottomNav(
              tab: _tab,
              onTap: (i) => setState(() {
                _tab = i;
                _detailListing = null;
              }),
            ),
    );
  }
}

// ── Tab body switcher ─────────────────────────────────────────────────────────
class _TabBody extends StatelessWidget {
  final int tab;
  final void Function(Listing) onListingTap;
  final VoidCallback onCreateSuccess;
  final VoidCallback onLogout;

  const _TabBody({
    required this.tab,
    required this.onListingTap,
    required this.onCreateSuccess,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      0 => HomeScreen(key: const ValueKey('home'), onListingTap: onListingTap),
      1 => MapScreen(key: const ValueKey('map'), onListingTap: onListingTap),
      2 => CreateListingScreen(
          key: const ValueKey('create'), onSuccess: onCreateSuccess),
      3 => const BookingsScreen(key: ValueKey('bookings')),
      4 => ProfileScreen(key: const ValueKey('profile'), onLogout: onLogout),
      _ => HomeScreen(key: const ValueKey('home'), onListingTap: onListingTap),
    };
  }
}

// ── Custom bottom nav bar ─────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.tab, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8), // Reduced bottom margin
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withOpacity(0.85),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home', 0, tab, onTap),
                  _NavItem(Icons.map_outlined, Icons.map_rounded, 'Map', 1, tab, onTap),
                  
                  // Regular center icon without background
                  _CenterIcon(index: 2, current: tab, onTap: onTap),

                  _NavItem(Icons.local_shipping_outlined, Icons.local_shipping_rounded, 'Orders', 3, tab, onTap),
                  _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile', 4, tab, onTap),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterIcon extends StatelessWidget {
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _CenterIcon({
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool active = current == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: 250.ms,
              curve: Curves.easeOutCubic,
              child: Icon(
                active ? Icons.add_circle_rounded : Icons.add_circle_outline_rounded,
                color: active ? Colors.blueAccent : Colors.white60,
                size: active ? 28 : 24,
              ),
            ),
            const SizedBox(height: 4),
            // Glowing Dot Indicator
            AnimatedContainer(
              duration: 200.ms,
              width: active ? 5 : 0,
              height: active ? 5 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.8),
                    blurRadius: 4,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData off;
  final IconData on;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem(this.off, this.on, this.label, this.index, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    bool active = current == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: 250.ms,
              curve: Curves.easeOutCubic,
              child: Icon(
                active ? on : off,
                color: active ? Colors.blueAccent : Colors.white60,
                size: active ? 28 : 24,
              ),
            ),
            const SizedBox(height: 4),
            // Glowing Dot Indicator
            AnimatedContainer(
              duration: 200.ms,
              width: active ? 5 : 0,
              height: active ? 5 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.8),
                    blurRadius: 4,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
