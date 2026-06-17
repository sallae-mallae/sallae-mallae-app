import 'package:flutter/material.dart';

abstract final class AppColors {
  // Main
  static const primary = Color(0xFF9571FA);
  static const secondary = Color(0xFF9571FA);
  static const blue = primary;
  static const purple = Color(0xFF9571FA);

  // Text
  static const textPrimary = Color(0xFF1B1D2A);
  static const textSecondary = Color(0xFF7B8093);
  static const textTertiary = Color(0xFFA3A8B8);
  static const textInverse = Color(0xFFFFFFFF);

  // Status
  static const buy = Color(0xFF25C997);
  static const consider = Color(0xFFFFB84D);
  static const pass = Color(0xFFFF6B6B);
  static const unknown = Color(0xFF8C94A8);

  // Background
  static const softBlue = Color(0xFFF2F8FF);
  static const lavender = Color(0xFFF3EFFF);
  static const cardWhite = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF7FAFF);
  static const screenBase = Color(0xFFFBFDFF);
  static const keyboardSurface = Color(0xFFE9ECF3);
  static const cameraScrim = Color(0x66000000);

  // UI Supporting
  static const lightBlueSurface = Color(0xFFEEF4FF);
  static const inputSurface = Color(0xFFF7FAFF);
  static const disabledSoftButton = Color(0xFFF4F7FC);
  static const border = Color(0x1F536289);
  static const deviceBorder = Color(0x29536289);
  static const shadow = Color(0x1F1B1D2A);
  static const elevatedShadow = Color(0x334E5D88);

  static const appBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9FCFF), Color(0xFFECF7FF), Color(0xFFF3EEFF)],
    stops: [0, 0.42, 1],
  );

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF7C5CF6)],
  );
}
