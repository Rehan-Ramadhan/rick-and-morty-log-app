import 'package:flutter/material.dart';

/// Core color tokens for the Rick & Morty Log dark sci-fi laboratory palette.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF080D12);
  static const Color secondaryBackground = Color(0xFF0D151B);
  static const Color surface = Color(0xFF111B22);
  static const Color elevatedSurface = Color(0xFF19262D);

  static const Color primaryNeonGreen = Color(0xFFB7F34A);
  static const Color portalCoreGreen = Color(0xFF6AE82F);
  static const Color cyan = Color(0xFF52E5E5);
  static const Color purple = Color(0xFF9B75E8);

  static const Color mainText = Color(0xFFF2F5E9);
  static const Color secondaryText = Color(0xFF91A0A4);
  static const Color error = Color(0xFFFF6B75);
  static const Color warning = Color(0xFFFFBE55);

  static const Color borderSubtle = Color(0xFF23343E);
  static const Color borderGlow = Color(0x66B7F34A);

  static const LinearGradient portalGradient = LinearGradient(
    colors: [primaryNeonGreen, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient spaceSurfaceGradient = LinearGradient(
    colors: [surface, secondaryBackground],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dimensionalGradient = LinearGradient(
    colors: [Color(0x33B7F34A), Color(0x2252E5E5), Color(0x229B75E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
