import 'package:flutter/material.dart';

class AppColors {
  static const purple = Color(0xFF5100B1);
  static const purpleDark = Color(0xFF3D0085);
  static const purpleLight = Color(0xFF9B51E0);
  static const purpleSoft = Color(0xFFEDE0F7);
  static const orange = Color(0xFFFF8C00);
  static const orangeRed = Color(0xFFFF4500);
  static const greenAccent = Color(0xFF22C55E);

  static const text = Color(0xFF1A1523);
  static const textMuted = Color(0xFF5C5470);
  static const border = Color(0xFFDDD0EC);
  static const background = Color(0xFFF0EAF8);
  static const card = Colors.white;

  static const textDark = Color(0xFFF5F0FA);
  static const textMutedDark = Color(0xFFB8AEC9);
  static const borderDark = Color(0xFF3D3350);
  static const backgroundDark = Color(0xFF120A1C);
  static const cardDark = Color(0xFF1E1529);
  static const surfaceDark = Color(0xFF251B33);
}

extension AppThemeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get appText => isDarkMode ? AppColors.textDark : AppColors.text;
  Color get appTextMuted => isDarkMode ? AppColors.textMutedDark : AppColors.textMuted;
  Color get appBorder => isDarkMode ? AppColors.borderDark : AppColors.border;
  Color get appCard => isDarkMode ? AppColors.cardDark : AppColors.card;
  Color get appBackground => isDarkMode ? AppColors.backgroundDark : AppColors.background;
}

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.purple,
        brightness: brightness,
        primary: AppColors.purple,
        secondary: AppColors.orange,
        surface: isDark ? AppColors.surfaceDark : Colors.white,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
        ),
        color: isDark ? AppColors.cardDark : Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        indicatorColor: isDark ? AppColors.purple.withValues(alpha: 0.35) : AppColors.purpleSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.purpleLight : AppColors.purple,
            );
          }
          return TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: isDark ? AppColors.purpleLight : AppColors.purple);
          }
          return IconThemeData(color: isDark ? AppColors.textMutedDark : AppColors.textMuted);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : Colors.white,
        labelStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
        hintStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.borderDark : AppColors.border,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.orange,
        textColor: isDark ? AppColors.textDark : AppColors.text,
        subtitleTextStyle: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.orange;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.orange.withValues(alpha: 0.45);
          }
          return isDark ? AppColors.borderDark : AppColors.border;
        }),
      ),
    );
  }
}
