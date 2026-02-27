import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _primary = Colors.deepPurple;

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.kantumruyPro().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
      surface: const Color(0xFFF8F9FD),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FD),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.kantumruyPro(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.black87),
      bodyMedium: GoogleFonts.kantumruyPro(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black87),
      bodySmall: GoogleFonts.kantumruyPro(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black54),
      titleMedium: GoogleFonts.kantumruyPro(fontWeight: FontWeight.w800, fontSize: 24, color: Colors.black, height: 1.2),
      titleLarge: GoogleFonts.kantumruyPro(fontWeight: FontWeight.w900, fontSize: 28, color: Colors.black, height: 1.2),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.kantumruyPro(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.w900,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: GoogleFonts.kantumruyPro(fontSize: 20, fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: GoogleFonts.kantumruyPro(fontWeight: FontWeight.w600, fontSize: 18),
      hintStyle: GoogleFonts.kantumruyPro(fontWeight: FontWeight.w500, fontSize: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: GoogleFonts.kantumruyPro(fontWeight: FontWeight.w600),
    ),
  );
}
