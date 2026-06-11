import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // Text styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
  );

  // Button styles
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final ButtonStyle secondaryButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.border),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  // Border radius
  // Border radius
  static const double borderRadius = 12.0;
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(4));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusXLarge = BorderRadius.all(
    Radius.circular(16),
  );

  // Dividers
  static const Color divider = Color(0xFFE5E7EB);

  // Shadows
  static const BoxShadow shadowSmall = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow shadowMedium = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowLarge = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );
}
