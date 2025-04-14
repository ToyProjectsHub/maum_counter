import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class HooponoponoScreen extends StatefulWidget {
  const HooponoponoScreen({super.key});

  @override
  State<HooponoponoScreen> createState() => _HooponoponoScreenState();
}

class _HooponoponoScreenState extends State<HooponoponoScreen> {
  final List<String> phrases = ['사랑합니다', '감사합니다', '미안합니다', '용서하세요'];
  int currentIndex = 0;
  int count = 0;
  late Box box;
  Timer? _resetTimer;

  String todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    box = Hive.box('hooponoponoBox');
    checkAndResetDailyCount();
    scheduleDailyReset();
    loadData();
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void scheduleDailyReset() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = nextMidnight.difference(now);

    Timer(durationUntilMidnight, () async {
      await checkAndResetDailyCount();
      _resetTimer = Timer.periodic(const Duration(days: 1), (_) {
        checkAndResetDailyCount();
      });
    });
  }

  Future<void> checkAndResetDailyCount() async {
    final today = todayKey();
    final lastReset = box.get('lastResetDate');

    if (lastReset != today) {
      await box.put('setCount', 0);
      await box.put('lastResetDate', today);
      loadData();
    }
  }

  void loadData() {
    setState(() {
      count = box.get('setCount', defaultValue: 0);
    });
  }

  void handlePhraseTap() {
    setState(() {
      currentIndex++;
      if (currentIndex >= phrases.length) {
        currentIndex = 0;
        count += 1;
        box.put('setCount', count);

        // 통계 저장 (일간)
        final statsBox = Hive.box('hooponoponoStats');
        final today = todayKey();
        final todayCount = statsBox.get(today, defaultValue: 0);
        statsBox.put(today, todayCount + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String currentPhrase = phrases[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('호오포노포노'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: '통계 보기',
            onPressed: () => Navigator.pushNamed(context, '/hooponoponoStats'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final topSpacing = constraints.maxHeight * 0.35;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: topSpacing),

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: ElevatedButton(
                      onPressed: handlePhraseTap,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        currentPhrase,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Text(
                    '실행 횟수: $count회',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}