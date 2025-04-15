import 'package:flutter/material.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  // 싱글톤 인스턴스
  static final ThemeController instance = ThemeController._internal();

  ThemeController._internal() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    value = mode;
  }

  void setThemeFromLabel(String label) {
    switch (label) {
      case '라이트':
        setThemeMode(ThemeMode.light);
        break;
      case '다크':
        setThemeMode(ThemeMode.dark);
        break;
      case '시스템':
      default:
        setThemeMode(ThemeMode.system);
    }
  }

  String getThemeLabel() {
    switch (value) {
      case ThemeMode.light:
        return '라이트';
      case ThemeMode.dark:
        return '다크';
      case ThemeMode.system:
      default:
        return '시스템';
    }
  }
}