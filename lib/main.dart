import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:maum_counter/theme/app_theme.dart';
import 'package:maum_counter/controller/theme_controller.dart';

import 'screens/home_screen.dart';
import 'screens/affirmation_screen.dart';
import 'screens/affirmation_stats_screen.dart';
import 'screens/hooponopono_screen.dart';
import 'screens/hooponopono_stats_screen.dart';
import 'screens/releasing_screen.dart';
import 'screens/releasing_stats_screen.dart';
import 'screens/simple_holistic_releasing_screen.dart';
import 'screens/simple_holistic_releasing_stats_screen.dart';
import 'screens/full_holistic_releasing_screen.dart';
import 'screens/full_holistic_releasing_stats_screen.dart';
import 'screens/setting_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // 모든 Hive 박스 열기
  final boxes = [
    'affirmationBox',
    'affirmationStats',
    'hooponoponoBox',
    'hooponoponoStats',
    'releasingBox',
    'releasingStats',
    'simpleHolisticBox',
    'simpleHolisticStats',
    'fullHolisticBox',
    'fullHolisticStats',
  ];

  for (final box in boxes) {
    await Hive.openBox(box);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, mode, _) {
        return MaterialApp(
          title: '마음 카운터',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/affirmation': (context) => const AffirmationScreen(),
            '/affirmationStats': (context) => const AffirmationStatsScreen(),
            '/hooponopono': (context) => const HooponoponoScreen(),
            '/hooponoponoStats': (context) => const HooponoponoStatsScreen(),
            '/releasing': (context) => const ReleasingScreen(),
            '/releasingStats': (context) => const ReleasingStatsScreen(),
            '/simpleHolistic': (context) => const SimpleHolisticReleasingScreen(),
            '/simpleHolisticStats': (context) => const SimpleHolisticStatsScreen(),
            '/fullHolistic': (context) => const FullHolisticReleasingScreen(),
            '/fullHolisticStats': (context) => const FullHolisticReleasingStatsScreen(),
            '/settings': (context) => const SettingScreen(),
          },
        );
      },
    );
  }
}
