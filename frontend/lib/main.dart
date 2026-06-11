import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/routes/app_routes.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/local_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalCacheService.init();
  await AuthService().init();
  runApp(const ProviderScope(child: MoodTrackerApp()));
}

class MoodTrackerApp extends StatelessWidget {
  const MoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: AppColors.darkBackground,
      ),
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.dashboard: (context) => const DashboardScreen(),
      },
    );
  }
}
