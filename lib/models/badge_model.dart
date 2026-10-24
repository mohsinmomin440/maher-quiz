import 'package:flutter/material.dart';

class BadgeModel {
  final String id;
  final String titleGu;
  final String titleEn;
  final String descGu;
  final String descEn;
  final String iconKey;
  final Color primaryColor;
  final bool isUnlocked;
  final int currentProgress;
  final int maxProgress;
  final String? unlockedDate;

  BadgeModel({
    required this.id,
    required this.titleGu,
    required this.titleEn,
    required this.descGu,
    required this.descEn,
    required this.iconKey,
    required this.primaryColor,
    required this.isUnlocked,
    required this.currentProgress,
    required this.maxProgress,
    this.unlockedDate,
  });

  double get progressPercentage {
    if (maxProgress <= 0) return 0.0;
    return (currentProgress / maxProgress).clamp(0.0, 1.0);
  }
}
