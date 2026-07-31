import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryGold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  size: 56,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'DSS Lets',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentWhite,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find Your Next Home',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.secondaryGold.withOpacity(0.9),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.secondaryGold.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
