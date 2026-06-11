import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _navigate);
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
    } else if (hasSeenOnboarding) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.purplePinkGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  boxShadow: [AppStyles.shadowLarge],
                ),
                child: const Text('😊', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 12),
              Text(
                'Mood Tracker',
                style: AppStyles.headlineSmall.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
