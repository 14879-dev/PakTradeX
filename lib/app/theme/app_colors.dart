import 'package:flutter/material.dart';

/// Centralized color palette for PakTradeX fintech application.
/// White + Blue Premium Fintech Theme.
abstract class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF1264E5); // Vibrant Fintech Blue
  static const Color primaryDark = Color(0xFF0D4DB5);
  static const Color primaryLight = Color(0xFFEAF3FF); // Light Blue tint
  static const Color navy = Color(0xFF0B1F3A); // Deep Navy

  // Background & Surfaces
  static const Color background = Color(0xFFF7F9FC); // Off-white modern bg
  static const Color surface = Color(0xFFFFFFFF); // Pure white card surface
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF172033); // High-contrast dark slate
  static const Color textSecondary = Color(0xFF64748B); // Muted slate gray
  static const Color textTertiary = Color(0xFF94A3B8); // Light placeholder slate
  static const Color textInverse = Color(0xFFFFFFFF);

  // Financial Semantics (Accessible + Distinct)
  static const Color success = Color(0xFF16A34A); // Profit Green
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color danger = Color(0xFFDC2626); // Loss Red
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B); // Caution Orange
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFEDF2F7);

  // Shimmer / Skeletons
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // Accent / AI Badges
  static const Color aiAccent = Color(0xFF7C3AED); // AI Purple tint
  static const Color aiAccentLight = Color(0xFFF3E8FF);
}
