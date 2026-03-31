import 'package:flutter/material.dart';

// Tema dell'app: palette colori, gradienti, spaziature e widget helper.
class AppTheme {
  AppTheme._();

  // Colori principali
  static const Color backgroundMain = Color(0xFFF7F8FB);
  static const Color cardBackground = Colors.white;
  static const Color primaryDark = Color(0xFF1D2671);
  static const Color primaryMedium = Color(0xFF0B5394);
  static const Color primaryiOS = Color(0xFF007AFF);
  static const Color primaryiOSLight = Color(0xFF0A84FF);
  static const Color textPrimary = Color(0xFF1D1D1F);
  static const Color textSecondary = Color(0xFF6E6E73);
  static const Color textTertiary = Color(0xFF8E8E93);

  // Colori per status badge
  static const Color statusSuccess = Colors.green;
  static const Color statusWarning = Colors.orange;
  static const Color statusInfo = Colors.blueGrey;

  // Colori accento
  static const Color accentIndigo = Colors.indigo;
  static const Color accentTeal = Colors.teal;
  static const Color accentPurple = Colors.deepPurple;
  static const Color accentAmber = Colors.amber;

  // Background per sezioni speciali
  static const Color darkBackground = Color(0xFF0B1225);
  static const Color surfaceLight = Color(0xFFF2F2F7);

  // Gradienti
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [primaryDark, primaryMedium],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientDark = LinearGradient(
    colors: [Color(0xFF141E30), Color(0xFF243B55)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient gradientLogo = LinearGradient(
    colors: [Colors.blue[600]!, Colors.blue[400]!],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Border radius

  static const double radiusCard = 18.0;
  static const double radiusCardLarge = 20.0;
  static const double radiusMedium = 14.0;
  static const double radiusSmall = 12.0;
  static const double radiusButton = 16.0;
  static const double radiusModal = 24.0;
  static const double radiusPill = 14.0;

  // Spaziature

  static const double paddingCard = 16.0;
  static const double paddingCardLarge = 20.0;
  static const double paddingSection = 24.0;
  static const double paddingScreen = 20.0;
  static const double gapSmall = 8.0;
  static const double gapMedium = 12.0;
  static const double gapLarge = 16.0;
  static const double gapXLarge = 20.0;

  // Ombre
  static List<BoxShadow> get shadowCard => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get shadowCardMedium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadowCardLarge => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get shadowButton => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ];

  // Stili testo

  static const String fontFamily = 'SF Pro Display';

  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    fontFamily: fontFamily,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textTertiary,
    fontFamily: fontFamily,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: textTertiary,
    fontFamily: fontFamily,
    letterSpacing: 0.2,
  );

  static const TextStyle bodyWhite = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    fontFamily: fontFamily,
  );

  // Decorazioni riutilizzabili
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? cardBackground,
        borderRadius: BorderRadius.circular(radiusCard),
        boxShadow: shadowCard,
      );

  static BoxDecoration cardDecorationLarge({Color? color}) => BoxDecoration(
        color: color ?? cardBackground,
        borderRadius: BorderRadius.circular(radiusCardLarge),
        boxShadow: shadowCardMedium,
      );

  static BoxDecoration pillDecoration(Color color, {bool subtle = true}) =>
      BoxDecoration(
        color: color.withOpacity(subtle ? 0.08 : 0.12),
        border: Border.all(
          color: color.withOpacity(subtle ? 0.15 : 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(radiusPill),
      );

  static BoxDecoration avatarDecoration(Color color) => BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      );

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryMedium,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusButton),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: paddingCardLarge,
      vertical: gapMedium,
    ),
  );

  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    side: BorderSide(color: primaryMedium.withOpacity(0.3)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    foregroundColor: primaryMedium,
    padding: const EdgeInsets.symmetric(
      horizontal: paddingCard,
      vertical: gapMedium,
    ),
  );

  // ThemeData globale

  static ThemeData get lightTheme => ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: fontFamily,
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundMain,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryiOS,
          brightness: Brightness.light,
          primary: primaryMedium,
          surface: cardBackground,
          background: backgroundMain,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cardBackground,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontFamily: fontFamily,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: primaryButtonStyle,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: outlinedButtonStyle,
        ),
        cardTheme: CardThemeData(
          color: cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: paddingCard,
            vertical: gapMedium,
          ),
        ),
      );

  // Widget helper
  static Widget buildPill({
    required String label,
    required String value,
    required Color color,
    bool uppercase = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pillDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            uppercase ? label.toUpperCase() : label,
            style: labelSmall.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildStatusBadge({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static Widget buildAvatar({
    required IconData icon,
    required Color color,
    double size = 40,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: avatarDecoration(color),
      child: Icon(
        icon,
        color: color,
        size: size * 0.55,
      ),
    );
  }
}
