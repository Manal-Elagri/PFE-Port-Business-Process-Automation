import 'package:flutter/material.dart';

class ThemeConfig {
  // Couleurs principales - Design moderne pour grande entreprise
  static const Color primaryColor = Color(0xFF1B42C4); // Bleu marine professionnel
  static const Color secondaryColor = Color(0xFF0F766E); // Teal accent
  static const Color accentColor = Color(0xFFF59E0B); // CORRIGÉ : Suppression de l'espace
  
  // Couleurs neutres
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF0A1628);
  static const Color textSecondaryColor = Color(0xFF5A6A8A);
  static const Color borderColor = Color(0xFFE2E8F0);
  
  // Couleurs fonctionnelles
  static const Color successColor = Color(0xFF10B981); // Vert
  static const Color errorColor = Color(0xFFEF4444);   // Rouge
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color infoColor = Color(0xFF3B82F6);    // Bleu
  
  // Shadows
  static final BoxShadow shadowSmall = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 2,
    offset: const Offset(0, 1),
  );
  
  static final BoxShadow shadowMedium = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
  
  static final BoxShadow shadowLarge = BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );

  // ThemeData complet
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
        // ignore: deprecated_member_use
        background: backgroundColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(color: textSecondaryColor),
        hintStyle: const TextStyle(color: textSecondaryColor),
      ),
      // CORRIGÉ : Utilisation de CardThemeData
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(0),
      ),
      // CORRIGÉ : Utilisation de DialogThemeData
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryColor,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryColor),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimaryColor),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimaryColor),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimaryColor),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimaryColor),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryColor),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryColor),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimaryColor),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimaryColor, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimaryColor, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, color: textSecondaryColor, height: 1.5),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimaryColor),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondaryColor),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondaryColor),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  // Utilitaires
  static BorderRadius borderRadiusSmall = BorderRadius.circular(6);
  static BorderRadius borderRadiusMedium = BorderRadius.circular(10);
  static BorderRadius borderRadiusLarge = BorderRadius.circular(16);

  static const EdgeInsets paddingSmall = EdgeInsets.all(8);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24);
}