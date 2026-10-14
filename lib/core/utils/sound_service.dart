import 'package:flutter/services.dart';

class SoundService {
  SoundService._();

  /// Play audio notification or haptic alert when a new order arrives in kitchen
  static Future<void> playOrderChime() async {
    try {
      // System sound click / alert
      await SystemSound.play(SystemSoundType.alert);
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Fallback silently if platform sound is disabled
    }
  }

  static Future<void> playSuccessChime() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Fallback silently
    }
  }
}
