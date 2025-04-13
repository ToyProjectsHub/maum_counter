import 'package:flutter/material.dart';
import 'package:maum_counter/screens/affirmation_screen.dart';
import 'screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/affirmation_stats_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // 박스(box) 열기 (데이터 저장 공간)
  await Hive.openBox('affirmationBox');
  await Hive.openBox('affirmationStats');
  await Hive.openBox('hooponoponoBox');
  await Hive.openBox('releasingBox');
  await Hive.openBox('holisticBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '마음 카운터',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/affirmation': (context) => const AffirmationScreen(),
        '/affirmationStats': (context) => const AffirmationStatsScreen(),
        '/hooponopono': (context) => const Placeholder(), // 호오포노포노 화면 연결 예정
        '/releasing': (context) => const Placeholder(), // 릴리징 화면 연결 예정
        '/holistic': (context) => const Placeholder(), // 심플 홀리스틱 릴리징
        '/settings': (context) => const Placeholder(), // 설정 화면
      },
    );
  }
}