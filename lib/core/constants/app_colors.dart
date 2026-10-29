import 'package:flutter/material.dart';

/// Design System: Warm Coffee Brown
/// Based on PRD section 2.1
class AppColors {
  AppColors._();

  // Primary Palette
  static const Color espressoDark = Color(0xFF38220F);
  static const Color roastedCoffee = Color(0xFF4A2E1B);
  static const Color warmCaramel = Color(0xFF8C5535);
  static const Color creamLatte = Color(0xFFEDE0D4);
  static const Color oatMilkFoam = Color(0xFFFAF7F2);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color softSand = Color(0xFFEFECE6);
  static const Color activePillCream = Color(0xFFF6E7D2);
  static const Color darkBarcodeBg = Color(0xFF1E232A);
  static const Color darkCoffeeHeader = Color(0xFF362117);

  // Semantic & Operational Status
  static const Color matchaGreen = Color(0xFF2E7D32);
  static const Color amberOrange = Color(0xFFE65100);
  static const Color berryRed = Color(0xFFC62828);
  static const Color coldBrewBlue = Color(0xFF1E3A8A);

  // Neutral & Functional
  static const Color textPrimary = Color(0xFF23160D);
  static const Color textSecondary = Color(0xFF6B584C);
  static const Color textMuted = Color(0xFF9E8E82);
  static const Color borderSubtle = Color(0xFFEADBCE);
  static const Color divider = Color(0xFFF0E7DD);

  // Figma Exact Modern Design System
  static const Color figmaCoffee = Color(0xFF563A2E);
  static const Color figmaCreamBg = Color(0xFFFDFAF7);
  static const Color figmaHazelnut = Color(0xFFB18368);
  static const Color figmaSubtleBorder = Color(0xFFEADBCE);
  static const Color figmaFieldBorder = Color(0xFFE8DDD3);
  static const Color figmaSoftCream = Color(0xFFF5EFE9);
  static const Color figmaPromoTag = Color(0xFFE8B896);
  static const Color figmaRedPin = Color(0xFFC44536);
  static const Color figmaGoogleBorder = Color(0xFFEAE2D9);
  static const Color figmaWhatsAppGreen = Color(0xFF25D366);
  static const Color figmaReadyGreen = Color(0xFF059669);
  static const Color figmaReadyBg = Color(0xFFD1FAE5);
  static const Color figmaStockTeal = Color(0xFF0D9488);
  static const Color figmaStockBg = Color(0xFFCCFBF1);
  static const Color figmaLimitedGreen = Color(0xFF10B981);
  static const Color figmaNavDock = Color(0xFF4A3225);

  // Gradients
  static const LinearGradient coffeeGradient = LinearGradient(
    colors: [espressoDark, roastedCoffee],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmCaramelGradient = LinearGradient(
    colors: [warmCaramel, roastedCoffee],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
