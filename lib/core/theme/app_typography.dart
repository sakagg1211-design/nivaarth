import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  static const heading1 = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.08,
  );

  static const heading2 = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.15,
  );

  static const title = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const body = TextStyle(
    color: AppColors.textSecondary,
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.42,
  );

  static const caption = TextStyle(
    color: AppColors.textTertiary,
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const metric = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.05,
  );
}
