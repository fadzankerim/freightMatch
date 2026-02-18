import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freight_match/models/listing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Your custom imports - ensure these paths match your folder structure
import 'config/theme.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart'; // Assume you have this for the "Main Shell"

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const ProviderScope(child: FreightMatchApp()));
}

// ── App State Enum ──────────────────────────────────────────────────────────
enum AppStatus { splashing, auth, mainShell }

class FreightMatchApp extends StatefulWidget {
  const FreightMatchApp({super.key});

  @override
  State<FreightMatchApp> createState() => _FreightMatchAppState();
}

class _FreightMatchAppState extends State<FreightMatchApp> {
  AppStatus _status = AppStatus.splashing;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreightMatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark, // Using your custom theme
      home: _buildCurrentScreen(),
    );
  }

  // This logic decides what the user sees
  Widget _buildCurrentScreen() {
    switch (_status) {
      case AppStatus.splashing:
        return SplashScreen(
          onComplete: () => setState(() => _status = AppStatus.auth),
        );
      case AppStatus.auth:
        return _AuthFlow(
          onLoginSuccess: () => setState(() => _status = AppStatus.mainShell),
        );
      case AppStatus.mainShell:
        return const _MainShell(); 
    }
  }
}

// ── Auth Flow: Toggle between Login & Register ──────────────────────────────
class _AuthFlow extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const _AuthFlow({required this.onLoginSuccess});

  @override
  State<_AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<_AuthFlow> {
  bool _showRegister = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: 300.ms,
        child: _showRegister
            ? RegisterScreen(
                key: const ValueKey('reg'),
                onSuccess: widget.onLoginSuccess,
                onGoLogin: () => setState(() => _showRegister = false),
              )
            : LoginScreen(
                key: const ValueKey('login'),
                onSuccess: widget.onLoginSuccess,
                onGoRegister: () => setState(() => _showRegister = true),
              ),
      ),
    );
  }
}

// ── Main Shell: The part with your Bottom Nav ───────────────────────────────
class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  // These would be your actual screens from your 'screens/' folder
  final List<Widget> _pages = [
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _BottomNav(
        tab: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

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