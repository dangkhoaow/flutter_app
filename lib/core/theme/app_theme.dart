import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── VIB Design Tokens ────────────────────────────────────────────────────────

class VibColors {
  VibColors._();

  static const navyDark   = Color(0xFF0F1A3D);
  static const navy       = Color(0xFF1A2B5F);
  static const navyLight  = Color(0xFF2A3F7A);
  static const brand      = Color(0xFFF7931E);
  static const brandY     = Color(0xFFFFc629);
  static const teal       = Color(0xFF2A9D8F);
  static const tealLight  = Color(0xFF40C9A2);
  static const danger     = Color(0xFFE63946);
  static const dangerLight= Color(0xFFFF6B6B);
  static const purple     = Color(0xFF7B2CBF);
  static const info       = Color(0xFF00ACC1);
  static const bg         = Color(0xFFF5F7FA);
  static const surface    = Color(0xFFFFFFFF);
  static const border     = Color(0xFFE8ECF1);
  static const textDark   = Color(0xFF1A2B5F);
  static const textMid    = Color(0xFF555555);
  static const textLight  = Color(0xFF999999);

  // Gradients
  static const gradNavy   = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [navyDark, navy],
  );
  static const gradBrand  = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [brand, brandY],
  );
  static const gradTeal   = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [teal, tealLight],
  );
  static const gradDanger = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [danger, dangerLight],
  );
}

class VibRadius {
  VibRadius._();
  static const sm  = BorderRadius.all(Radius.circular(8));
  static const md  = BorderRadius.all(Radius.circular(12));
  static const lg  = BorderRadius.all(Radius.circular(14));
  static const xl  = BorderRadius.all(Radius.circular(20));
  static const pill= BorderRadius.all(Radius.circular(9999));
}

class VibShadow {
  VibShadow._();
  static const sm = [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0,2))];
  static const md = [BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0,4))];
  static const lg = [BoxShadow(color: Color(0x26000000), blurRadius: 40, offset: Offset(0,10))];
}

// ── AppTheme ──────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: VibColors.brand,
        primary: VibColors.navy,
        secondary: VibColors.brand,
        surface: VibColors.surface,
        error: VibColors.danger,
      ),
      scaffoldBackgroundColor: VibColors.bg,
      textTheme: GoogleFonts.beVietnamProTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.beVietnamPro(fontSize: 24, fontWeight: FontWeight.w800, color: VibColors.navyDark),
        headlineMedium: GoogleFonts.beVietnamPro(fontSize: 20, fontWeight: FontWeight.w800, color: VibColors.navyDark),
        titleLarge: GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: FontWeight.w700, color: VibColors.navyDark),
        titleMedium: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600, color: VibColors.textDark),
        bodyLarge: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w400, color: VibColors.textMid),
        bodySmall: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w400, color: VibColors.textLight),
        labelSmall: GoogleFonts.beVietnamPro(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.1, color: VibColors.textLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: VibColors.surface,
        foregroundColor: VibColors.navyDark,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VibColors.brand,
          foregroundColor: VibColors.navyDark,
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w700, fontSize: 13),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VibColors.textMid,
          side: const BorderSide(color: VibColors.border, width: 1.5),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, fontSize: 13),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VibColors.bg,
        border: OutlineInputBorder(borderRadius: VibRadius.md, borderSide: const BorderSide(color: VibColors.border, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: VibRadius.md, borderSide: const BorderSide(color: VibColors.border, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: VibRadius.md, borderSide: const BorderSide(color: VibColors.brand, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: GoogleFonts.beVietnamPro(fontSize: 13, color: VibColors.textMid),
        hintStyle: GoogleFonts.beVietnamPro(fontSize: 13, color: VibColors.textLight),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        labelStyle: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      dividerTheme: const DividerThemeData(color: VibColors.border, thickness: 1),
      cardTheme: CardThemeData(
        elevation: 0,
        color: VibColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: VibRadius.md,
          side: const BorderSide(color: VibColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
