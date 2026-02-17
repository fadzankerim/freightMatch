import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'screens/auth/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar to light content for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  
  runApp(
    const ProviderScope(
      child: FreightMatchApp(),
    ),
  );
}

class FreightMatchApp extends StatelessWidget {
  const FreightMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreightMatch',
      debugShowCheckedModeBanner: false,
      
      // Your dark theme
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      
      // Start with splash screen
      home: const SplashScreen(),
    );
  }
}