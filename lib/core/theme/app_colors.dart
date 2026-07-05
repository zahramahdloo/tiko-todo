import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Status colors
  static const statusPending = Color(0xFFFF9F43);
  static const statusInProgress = Color(0xFF2463EB);
  static const statusCompleted = Color(0xFF00C9A7);
  static const statusCancelled = Color(0xFF94A3B8);

  // Priority colors
  static const priorityLow = Color(0xFF94A3B8);
  static const priorityNormal = Color(0xFF2463EB);
  static const priorityHigh = Color(0xFFFF9F43);
  static const priorityUrgent = Color(0xFFFF6B6B);

  // General
  static const primary = Color(0xFF2463EB);
  static const background = Color(0xFFF8F9FA);
  static const cardBackground = Colors.white;
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
}
