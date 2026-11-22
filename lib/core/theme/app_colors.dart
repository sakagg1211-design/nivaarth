import 'package:flutter/material.dart';

/// The palette. Dark is the default and the identity; light is "the same desk by day"
/// (spec 2026-11-22-light-dark-toggle). NivaarthApp sets [isLight] and remounts the app,
/// so every widget reads the current values on its next build.
class AppColors {
  static bool isLight = false;

  static Color _p(int dark, int light) => Color(isLight ? light : dark);
  static Color _soft(Color c) => c.withAlpha(0x1F);

  static Color get background => _p(0xFF0C0D10, 0xFFF6F5F1);
  static Color get surface => _p(0xFF16171B, 0xFFFFFFFF);
  static Color get surfaceSecondary => _p(0xFF23252B, 0xFFEFEDE7);
  static Color get ink => _p(0xFFFFFFFF, 0xFF15161A);
  static Color get inkSoft => _p(0xFFE5E7EB, 0xFF2A2C31);
  static Color get textPrimary => _p(0xFFFFFFFF, 0xFF15161A);
  static Color get textSecondary => _p(0xFF8E929B, 0xFF5C6068);
  static Color get textTertiary => _p(0xFF858A94, 0xFF6B6F78);
  static Color get line => _p(0xFF282A30, 0xFFE3E0D8);
  static Color get lineStrong => _p(0xFF383A42, 0xFFCFCBC1);
  static Color get accent => _p(0xFFE5A93C, 0xFFB07A1C);
  static Color get accentSoft => _soft(accent);
  static Color get mint => success;
  static Color get mintSoft => _soft(success);
  static Color get gold => accent;
  static Color get goldSoft => _soft(accent);
  static Color get success => _p(0xFF00E676, 0xFF0B8A55);
  // Darker green for solid fills under white text (success itself is too bright in dark)
  static Color get successFill => _p(0xFF0C9F6E, 0xFF0B8A55);
  static Color get successSoft => _soft(success);
  static Color get danger => _p(0xFFFF5252, 0xFFD33A3A);
  static Color get dangerSoft => _soft(danger);
  static Color get warning => _p(0xFFFF9800, 0xFFC26A00);
  static Color get warningSoft => _soft(warning);
  static Color get violet => _p(0xFFA78BFA, 0xFF6D4FD8);
  static Color get violetSoft => _soft(violet);
  // Sky blue for links and info chips; darker in light mode so it reads on white
  static Color get info => _p(0xFF38BDF8, 0xFF0369A1);
  // Compatibility aliases
  static Color get primary => accent;
  static Color get outline => line;
}
