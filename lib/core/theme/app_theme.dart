import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Material 3 dark sci-fi theme tailored for Rick & Morty Log.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.spaceGroteskTextTheme(
      ThemeData.dark().textTheme,
    );

    final displayFont = GoogleFonts.orbitron();

    final textTheme = baseTextTheme.copyWith(
      displayLarge: displayFont.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.mainText,
      ),
      displayMedium: displayFont.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: AppColors.mainText,
      ),
      headlineLarge: displayFont.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.mainText,
      ),
      headlineMedium: displayFont.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: AppColors.mainText,
      ),
      titleLarge: displayFont.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.mainText,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.mainText,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.5,
        color: AppColors.mainText,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.45,
        color: AppColors.secondaryText,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.4,
        color: AppColors.secondaryText,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.mainText,
      ),
    );

    const colorScheme = ColorScheme.dark(
      primary: AppColors.primaryNeonGreen,
      onPrimary: AppColors.background,
      secondary: AppColors.cyan,
      onSecondary: AppColors.background,
      tertiary: AppColors.purple,
      onTertiary: AppColors.mainText,
      surface: AppColors.surface,
      onSurface: AppColors.mainText,
      surfaceContainerHighest: AppColors.elevatedSurface,
      error: AppColors.error,
      onError: AppColors.background,
      outline: AppColors.borderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.mainText),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryBackground,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText.withValues(alpha: 0.7),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText,
        ),
        prefixIconColor: AppColors.cyan,
        suffixIconColor: AppColors.secondaryText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryNeonGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.elevatedSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.mainText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
      ),
    );
  }
}
