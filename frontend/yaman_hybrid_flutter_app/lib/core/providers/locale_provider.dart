import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('ar'));

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(AppConstants.languageKey) ?? 'ar';
      state = Locale(languageCode);
    } catch (e) {
      debugPrint('Error loading locale: $e');
      state = const Locale('ar');
    }
  }

  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.languageKey, locale.languageCode);
      state = locale;
    } catch (e) {
      debugPrint('Error setting locale: $e');
    }
  }

  Future<void> toggleLanguage() async {
    final newLocale =
        state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await setLocale(newLocale);
  }

  bool get isArabic => state.languageCode == 'ar';
  bool get isEnglish => state.languageCode == 'en';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

// Helper extension for RTL support
extension LocaleExtension on Locale {
  bool get isRTL => languageCode == 'ar';
  TextDirection get textDirection =>
      isRTL ? TextDirection.rtl : TextDirection.ltr;
}
