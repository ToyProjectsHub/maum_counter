import 'package:flutter/material.dart';
import 'package:maum_counter/screens/affirmation_screen.dart';
import 'package:maum_counter/screens/full_holistic_releasing_screen.dart';
import 'package:maum_counter/screens/full_holistic_releasing_stats_screen.dart';
import 'package:maum_counter/screens/hooponopono_screen.dart';
import 'package:maum_counter/screens/releasing_screen.dart';
import 'package:maum_counter/screens/releasing_stats_screen.dart';
import 'package:maum_counter/screens/setting_screen.dart';
import 'package:maum_counter/screens/simple_holistic_releasing_screen.dart';
import 'package:maum_counter/screens/simple_holistic_releasing_stats_screen.dart';
import 'screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:maum_counter/screens/affirmation_stats_screen.dart';
import 'package:maum_counter/screens/hooponopono_stats_screen.dart';
import 'package:maum_counter/theme/app_theme.dart';
import 'screens/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // 박스(box) 열기 (데이터 저장 공간)
  await Hive.openBox('affirmationBox');
  await Hive.openBox('affirmationStats');
  await Hive.openBox('hooponoponoBox');
  await Hive.openBox('hooponoponoStats');
  await Hive.openBox('releasingBox');
  await Hive.openBox('releasingStats');
  await Hive.openBox('simpleHolisticBox');
  await Hive.openBox('simpleHolisticStats');
  await Hive.openBox('fullHolisticBox');
  await Hive.openBox('fullHolisticStats');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '마음 카운터',
      theme: AppTheme.light,
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
        '/settings': (context) => const SettingScreen(), // 설정 화면
      },
    );
  }
}