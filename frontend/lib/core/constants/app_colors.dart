import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  // Primary colors
  static const Color primary = Color(0xFF6B5B95); // Purple
  static const Color secondary = Color(0xFFD946A6); // Pink
  static const Color accent = Color(0xFFE8B4F3); // Lavender
  static const Color accentLight = Color(0xFFF0E6FF);

  // Mood level colors
  static const Color moodTerrible = Color(0xFFEF4444); // Red
  static const Color moodSad = Color(0xFFF97316); // Orange
  static const Color moodOkay = Color(0xFF3B82F6); // Blue
  static const Color moodGood = Color(0xFF10B981); // Green
  static const Color moodAmazing = Color(0xFF8B5CF6); // Purple

  // Aliases for mood levels
  static const Color terrible = moodTerrible;
  static const Color sad = moodSad;
  static const Color okay = moodOkay;
  static const Color good = moodGood;
  static const Color amazing = moodAmazing;

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF8F6FF);
  static const Color cardBackground = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // System colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF3B82F6);

  // Dark mode
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);

  // Gradients
  static const LinearGradient purplePinkGradient = LinearGradient(
    colors: [Color(0xFF6B5B95), Color(0xFFD946A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lavenderBlueGradient = LinearGradient(
    colors: [Color(0xFFE8B4F3), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient moodGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFD946A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
