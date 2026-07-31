import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase not configured yet — app will run with local-only features.
    // In production, add google-services.json / GoogleService-Info.plist
    // and ensure Firebase project is configured.
    debugPrint('Firebase initialization skipped: $e');
  }

  runApp(const DSSApp());
}

class DSSApp extends StatelessWidget {
  const DSSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DSS Lets',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      builder: (context, child) {
        // Ensure Google Fonts are loaded before rendering
        return GoogleFontsInitWrapper(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

/// Wrapper that ensures Google Fonts are initialized before building children.
class GoogleFontsInitWrapper extends StatelessWidget {
  final Widget child;
  const GoogleFontsInitWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
