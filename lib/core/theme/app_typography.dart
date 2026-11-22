import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  // ---------------------------------------------------------------------------
  // Existing Styles (Keep)
  // ---------------------------------------------------------------------------

  static TextStyle get heading1 => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.08,
  );

  static TextStyle get heading2 => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.15,
  );

  static TextStyle get title => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.20,
  );

  static TextStyle get body => TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.42,
  );

  static TextStyle get caption => TextStyle(
    color: AppColors.textTertiary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static TextStyle get metric => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.05,
  );

  // ---------------------------------------------------------------------------
  // Material 3 Compatible Styles
  // ---------------------------------------------------------------------------

  static TextStyle get displaySmall => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.05,
  );

  static TextStyle get headlineSmall => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  static TextStyle get titleLarge => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.20,
  );

  static TextStyle get titleMedium => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static TextStyle get bodyLarge => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  static TextStyle get bodyMedium => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  static TextStyle get bodySmall => TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static TextStyle get labelMedium => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static TextStyle get labelSmall => TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.20,
  );
  static TextStyle get headlineMedium => TextStyle(
  color: AppColors.textPrimary,
  fontSize: 28,
  fontWeight: FontWeight.w800,
  height: 1.10,
);
}