import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const fundo = Color(0xFFFAF8F5);
  static const superficie = Colors.white;
  static const ouro = Color(0xFFD4AF37);
  static const champagne = Color(0xFFF7E7CE);
  static const roseGold = Color(0xFFB76E79);
  static const texto = Color(0xFF2C3E50);
  static const aprovado = Color(0xFF9CAF88);  // verde sálvia
  static const pendente = Color(0xFFE2A98B);  // pêssego/terracota
  static const sage = Color(0xFF8FA98B);      // aprovado
  static const pessego = Color(0xFFE8A87C);   // pendente
  static const terracota = Color(0xFFC96F5A); // recusado / exclusão
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.fundo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ouro,
        primary: AppColors.ouro,
        surface: AppColors.superficie,
      ),
      textTheme: GoogleFonts.montserratTextTheme(base.textTheme).copyWith(
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: AppColors.texto,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.texto,
        ),
      ).apply(bodyColor: AppColors.texto, displayColor: AppColors.texto),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.texto,
      ),
      cardTheme: CardThemeData(
        color: AppColors.superficie,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static List<BoxShadow> get sombraSutil => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}