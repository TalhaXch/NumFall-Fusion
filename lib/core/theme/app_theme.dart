import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Application theme configuration
/// Provides complete dark and light theme definitions with adaptive colors
class AppTheme {
  const AppTheme._();

  // Brand colors
  static const Color primaryLight = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color accentLight = Color(0xFFEC4899); // Pink
  static const Color accentDark = Color(0xFFF472B6);

  // Background gradients
  static const List<Color> backgroundGradientLight = [
    Color(0xFFF8FAFC),
    Color(0xFFE0E7FF),
  ];

  static const List<Color> backgroundGradientDark = [
    Color(0xFF0F172A),
    Color(0xFF1E293B),
  ];

  /// Get light theme data
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: primaryLight,
      secondary: accentLight,
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1E293B),
      surfaceContainerHighest: Color(0xFFF1F5F9),
      error: Color(0xFFEF4444),
      onError: Color(0xFFFFFFFF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundGradientLight[0],
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1E293B),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: colorScheme.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF475569),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF475569),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  /// Get dark theme data
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: primaryDark,
      secondary: accentDark,
      surface: Color(0xFF1E293B),
      onSurface: Color(0xFFF8FAFC),
      surfaceContainerHighest: Color(0xFF334155),
      error: Color(0xFFF87171),
      onError: Color(0xFF0F172A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundGradientDark[0],
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF8FAFC),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: colorScheme.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: primaryDark,
          foregroundColor: Color(0xFF0F172A),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF8FAFC),
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF8FAFC),
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF8FAFC),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFFCBD5E1),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFFCBD5E1),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  /// Get tile color based on value and theme brightness
  static Color getTileColor(int value, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // Color scale from blue to purple to pink
    final colorMap = <int, Color>{
      2: isDark ? const Color(0xFF3B82F6) : const Color(0xFF60A5FA),
      4: isDark ? const Color(0xFF8B5CF6) : const Color(0xFFA78BFA),
      8: isDark ? const Color(0xFFEC4899) : const Color(0xFFF472B6),
      16: isDark ? const Color(0xFFF97316) : const Color(0xFFFB923C),
      32: isDark ? const Color(0xFFEAB308) : const Color(0xFFFBBF24),
      64: isDark ? const Color(0xFF84CC16) : const Color(0xFFA3E635),
      128: isDark ? const Color(0xFF10B981) : const Color(0xFF34D399),
      256: isDark ? const Color(0xFF06B6D4) : const Color(0xFF22D3EE),
      512: isDark ? const Color(0xFF6366F1) : const Color(0xFF818CF8),
      1024: isDark ? const Color(0xFF8B5CF6) : const Color(0xFFA78BFA),
      2048: isDark ? const Color(0xFFEC4899) : const Color(0xFFF472B6),
    };

    return colorMap[value] ??
        (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8));
  }

  /// Get gradient colors for background
  static List<Color> getBackgroundGradient(Brightness brightness) {
    return brightness == Brightness.dark
        ? backgroundGradientDark
        : backgroundGradientLight;
  }
}
