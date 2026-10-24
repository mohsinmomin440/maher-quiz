import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static const String _soundKey = 'maher_sound_enabled';
  static bool? _isSoundEnabledCache;

  // Check if sound effects are enabled (default: true)
  static Future<bool> isEnabled() async {
    if (_isSoundEnabledCache != null) return _isSoundEnabledCache!;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isSoundEnabledCache = prefs.getBool(_soundKey) ?? true;
      return _isSoundEnabledCache!;
    } catch (_) {
      return true;
    }
  }

  // Toggle sound effects on/off
  static Future<void> setEnabled(bool enabled) async {
    _isSoundEnabledCache = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundKey, enabled);
    } catch (_) {}
  }

  // Play pleasant correct answer feedback with vibration
  static Future<void> playCorrect() async {
    final enabled = await isEnabled();
    if (!enabled) return;

    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  // Play soft incorrect answer feedback with vibration
  static Future<void> playIncorrect() async {
    final enabled = await isEnabled();
    if (!enabled) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  // Play celebratory fan-fare / win vibration
  static Future<void> playVictory() async {
    final enabled = await isEnabled();
    if (!enabled) return;

    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
