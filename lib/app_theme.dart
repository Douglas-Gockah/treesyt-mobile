import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TreeSyt brand green — matches the AppBar / banner colour in designs.
const Color kPrimaryGreen = Color(0xFF18A369);
const Color kPrimaryGreenLight = Color(0xFFE8F5EE);
const Color kPrimaryGreenDark = Color(0xFF1E7A52);
const Color kScaffoldBg = Color(0xFFFAFAFA);
const Color kDivider = Color(0xFFE5E5E5);
const Color kTextPrimary = Color(0xFF171717);
const Color kTextSecondary = Color(0xFF737373);
const Color kRequiredRed = Color(0xFFD32F2F);

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    // Inter is the TreeSyt brand typeface. GoogleFonts.interTextTheme() applies
    // it to every text role (headline, body, label, etc.) in one call.
    // Fonts are fetched from Google CDN on first launch and cached on-device.
    // For fully-offline deployments, drop the Inter .ttf files into
    // assets/fonts/ and declare them in pubspec.yaml — google_fonts will
    // prefer the bundled copy automatically.
    textTheme: GoogleFonts.interTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryGreen,
      primary: kPrimaryGreen,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: kTextPrimary,
    ),
    scaffoldBackgroundColor: kScaffoldBg,
    appBarTheme: AppBarTheme(
      backgroundColor: kPrimaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: kPrimaryGreen,
      unselectedLabelColor: kTextSecondary,
      indicatorColor: kPrimaryGreen,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle:
          GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14),
      dividerColor: kDivider,
    ),
    dividerTheme: const DividerThemeData(
      color: kDivider,
      thickness: 1,
      space: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kPrimaryGreen, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(color: kTextSecondary, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle:
            GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    chipTheme: ChipThemeData(
      selectedColor: kPrimaryGreen,
      labelStyle: GoogleFonts.inter(fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
