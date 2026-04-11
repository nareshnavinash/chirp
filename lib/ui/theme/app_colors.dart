import 'dart:ui';

/// Semantic color palette for Chirp.
/// Organized by role, not hue — use these instead of hardcoded Colors.*.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────
  static const brand = Color(0xFF7C3AED); // violet-600
  static const brandLight = Color(0xFFB794F6); // violet-400
  static const brandSubtle = Color(0xFFF8F7F4); // off-white

  // ── Semantic states ────────────────────────────────────────────
  static const success = Color(0xFF16A34A); // green-600
  static const successLight = Color(0xFFDCFCE7); // green-100
  static const successMedium = Color(0xFF15803D); // green-700

  static const warning = Color(0xFFEA580C); // orange-600
  static const warningLight = Color(0xFFFFF7ED); // orange-50
  static const warningMedium = Color(0xFFFDBA74); // orange-300
  static const warningDark = Color(0xFFC2410C); // orange-700

  static const error = Color(0xFFDC2626); // red-600
  static const errorLight = Color(0xFFFEE2E2); // red-100
  static const errorDark = Color(0xFFB91C1C); // red-700

  // ── Neutral / text ─────────────────────────────────────────────
  static const textSecondary = Color(0xFF6B7280); // gray-500
  static const textTertiary = Color(0xFF9CA3AF); // gray-400
  static const surfaceSubtle = Color(0xFFF3F4F6); // gray-100
  static const border = Color(0xFFE5E7EB); // gray-200
  static const borderLight = Color(0xFFF3F4F6); // gray-100

  // ── Stats-specific accent colors ───────────────────────────────
  static const statsPurple = Color(0xFF7C3AED); // violet-600
  static const statsTeal = Color(0xFF0D9488); // teal-600
  static const statsAmber = Color(0xFFD97706); // amber-600

  // ── Break screen ───────────────────────────────────────────────
  static const breakGradientStart = Color(0xFF1E1035); // deep violet
  static const breakGradientEnd = Color(0xFF2D1B4E); // deep violet lighter

  // ── Dark mode overrides ────────────────────────────────────────
  static const darkBrand = Color(0xFFB794F6); // violet-400 for dark mode
  static const darkBrandSubtle = Color(0xFF2D1B4E); // deep violet

  static const darkSuccess = Color(0xFF4ADE80); // green-400
  static const darkSuccessLight = Color(0xFF14532D); // green-900
  static const darkSuccessMedium = Color(0xFF22C55E); // green-500

  static const darkWarning = Color(0xFFFB923C); // orange-400
  static const darkWarningLight = Color(0xFF431407); // orange-950
  static const darkWarningMedium = Color(0xFFFDBA74); // orange-300
  static const darkWarningDark = Color(0xFFF97316); // orange-500

  static const darkError = Color(0xFFF87171); // red-400
  static const darkErrorLight = Color(0xFF450A0A); // red-950
  static const darkErrorDark = Color(0xFFEF4444); // red-500

  static const darkTextSecondary = Color(0xFF9CA3AF); // gray-400
  static const darkTextTertiary = Color(0xFF6B7280); // gray-500
  static const darkSurfaceSubtle = Color(0xFF1F2937); // gray-800
  static const darkBorder = Color(0xFF374151); // gray-700
  static const darkBorderLight = Color(0xFF1F2937); // gray-800

  static const darkStatsPurple = Color(0xFFA78BFA); // violet-400
  static const darkStatsTeal = Color(0xFF2DD4BF); // teal-400
  static const darkStatsAmber = Color(0xFFFBBF24); // amber-400
}
