import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4361EE);
  static const Color primaryLight = Color(0xFF4895EF);
  static const Color primaryDark = Color(0xFF3A0CA3);
  static const Color secondary = Color(0xFF4CC9F0);
  
  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textDisabled = Color(0xFFADB5BD);
  static const Color textInverse = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  // Job Categories Colors
  static const Color techColor = Color(0xFF4361EE);
  static const Color designColor = Color(0xFF7209B7);
  static const Color marketingColor = Color(0xFFF72585);
  static const Color financeColor = Color(0xFF4CC9F0);
  static const Color hrColor = Color(0xFF2EC4B6);
  static const Color salesColor = Color(0xFFFF9F1C);
}