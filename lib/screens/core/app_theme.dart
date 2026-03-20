import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  // ─── COLORES COMPARTIDOS ───────────────────────────────
  static const Color primaryRed    = Color(0xFFD32F2F);
  static const Color redAccent     = Color(0xFFFF5252);
  static const Color redShadow     = Color(0x66D32F2F);

  // ─── DARK ──────────────────────────────────────────────
  static const Color darkBg        = Color(0xFF000000);
  static const Color darkSurface   = Color(0xFF111111);
  static const Color darkCard      = Color(0xFF1A1A1A);
  static const Color darkInput     = Color(0xFF1C1C1E);
  static const Color darkBorder    = Color(0xFF2A2A2A);
  static const Color darkTextPrim  = Color(0xFFFFFFFF);
  static const Color darkTextSec   = Color(0xFFAAAAAA);
  static const Color darkTextHint  = Color(0xFF666666);
  static const Color darkNavBar    = Color(0xFF0F0F0F);

  // ─── LIGHT ─────────────────────────────────────────────
  static const Color lightBg       = Color(0xFFF2F2F7); // iOS-style soft grey
  static const Color lightSurface  = Color(0xFFFFFFFF);
  static const Color lightCard     = Color(0xFFFFFFFF);
  static const Color lightInput    = Color(0xFFEAEAEF);
  static const Color lightBorder   = Color(0xFFDDDDDD);
  static const Color lightTextPrim = Color(0xFF111111);
  static const Color lightTextSec  = Color(0xFF555555);
  static const Color lightTextHint = Color(0xFF999999);
  static const Color lightNavBar   = Color(0xFFFFFFFF);

  // ──────────────────────────────────────────────────────
  // DARK THEME
  // ──────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: primaryRed,

    colorScheme: const ColorScheme.dark(
      primary:   primaryRed,
      onPrimary: Colors.white,
      secondary: redAccent,
      surface:   darkCard,
      onSurface: darkTextPrim,
      error:     redAccent,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: darkTextPrim, fontWeight: FontWeight.bold, fontSize: 32),
      titleLarge:   TextStyle(color: darkTextPrim, fontWeight: FontWeight.bold, fontSize: 20),
      bodyLarge:    TextStyle(color: darkTextSec,  fontSize: 16),
      bodyMedium:   TextStyle(color: darkTextSec,  fontSize: 14),
      bodySmall:    TextStyle(color: darkTextHint, fontSize: 12),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkInput,
      labelStyle:       const TextStyle(color: darkTextSec),
      hintStyle:        const TextStyle(color: darkTextHint),
      prefixIconColor:  darkTextHint,
      border:           _border(),
      enabledBorder:    _border(),
      focusedBorder:    _border(color: primaryRed, width: 1.5),
      errorBorder:      _border(color: redAccent),
      focusedErrorBorder: _border(color: redAccent, width: 1.5),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        disabledBackgroundColor: primaryRed.withOpacity(0.4),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: redShadow,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkTextPrim,
        side: const BorderSide(color: darkBorder),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: darkBorder),
      ),
    ),

    dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),

    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      surfaceTintColor: darkBg,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkTextPrim),
      titleTextStyle: TextStyle(
        color: darkTextPrim,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: darkNavBar,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkNavBar,
      selectedItemColor: primaryRed,
      unselectedItemColor: darkTextHint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkCard,
      contentTextStyle: const TextStyle(color: darkTextPrim),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? primaryRed : darkTextHint,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? primaryRed.withOpacity(0.4)
            : darkBorder,
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? primaryRed : Colors.transparent,
      ),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: darkTextHint),
    ),

    tabBarTheme: const TabBarThemeData(
      labelColor: primaryRed,
      unselectedLabelColor: darkTextHint,
      indicatorColor: primaryRed,
      indicatorSize: TabBarIndicatorSize.label,
    ),

    iconTheme: const IconThemeData(color: darkTextPrim),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: darkTextPrim),
    ),
  );

  // ──────────────────────────────────────────────────────
  // LIGHT THEME
  // ──────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: primaryRed,

    colorScheme: const ColorScheme.light(
      primary:   primaryRed,
      onPrimary: Colors.white,
      secondary: redAccent,
      surface:   lightCard,
      onSurface: lightTextPrim,
      error:     redAccent,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: lightTextPrim, fontWeight: FontWeight.bold, fontSize: 32),
      titleLarge:   TextStyle(color: lightTextPrim, fontWeight: FontWeight.bold, fontSize: 20),
      bodyLarge:    TextStyle(color: lightTextSec,  fontSize: 16),
      bodyMedium:   TextStyle(color: lightTextSec,  fontSize: 14),
      bodySmall:    TextStyle(color: lightTextHint, fontSize: 12),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightInput,
      labelStyle:       const TextStyle(color: lightTextSec),
      hintStyle:        const TextStyle(color: lightTextHint),
      prefixIconColor:  lightTextHint,
      border:           _border(),
      enabledBorder:    _border(),
      focusedBorder:    _border(color: primaryRed, width: 1.5),
      errorBorder:      _border(color: redAccent),
      focusedErrorBorder: _border(color: redAccent, width: 1.5),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        disabledBackgroundColor: primaryRed.withOpacity(0.4),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        shadowColor: redShadow,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightTextPrim,
        side: const BorderSide(color: lightBorder),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: lightBorder),
      ),
    ),

    dividerTheme: const DividerThemeData(color: lightBorder, thickness: 1),

    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      elevation: 0,
      surfaceTintColor: lightSurface,
      centerTitle: true,
      iconTheme: IconThemeData(color: lightTextPrim),
      titleTextStyle: TextStyle(
        color: lightTextPrim,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: lightNavBar,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightNavBar,
      selectedItemColor: primaryRed,
      unselectedItemColor: lightTextHint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: lightTextPrim,
      contentTextStyle: const TextStyle(color: lightSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? primaryRed : lightTextHint,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? primaryRed.withOpacity(0.3)
            : lightBorder,
      ),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? primaryRed : Colors.transparent,
      ),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: lightTextHint),
    ),

    tabBarTheme: const TabBarThemeData(
      labelColor: primaryRed,
      unselectedLabelColor: lightTextHint,
      indicatorColor: primaryRed,
      indicatorSize: TabBarIndicatorSize.label,
    ),

    iconTheme: const IconThemeData(color: lightTextPrim),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: lightTextPrim),
    ),
  );

  // ──────────────────────────────────────────────────────
  // HELPER
  // ──────────────────────────────────────────────────────
  static OutlineInputBorder _border({Color? color, double width = 0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: color != null
            ? BorderSide(color: color, width: width)
            : BorderSide.none,
      );
}