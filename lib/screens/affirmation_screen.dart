import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class AffirmationScreen extends StatefulWidget {
  const AffirmationScreen({super.key});

  @override
  State<AffirmationScreen> createState() => _AffirmationScreenState();
}

class _AffirmationScreenState extends State<AffirmationScreen> {
  final TextEditingController _controller = TextEditingController();
  late Box box;
  Timer? _dailyResetTimer;

  String currentAffirmation = '';
  int count = 0;
  List<String> favoriteList = [];

  String todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    box = Hive.box('affirmationBox');
    checkAndResetDailyCount();
    scheduleDailyReset(); // ✅ 자정 기준 리셋 예약
    loadData();
  }

  @override
  void dispose() {
    _dailyResetTimer?.cancel();
    super.dispose();
  }

  void scheduleDailyReset() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = nextMidnight.difference(now);

    // 1️⃣ 자정까지 기다린 후
    Timer(durationUntilMidnight, () async {
      await checkAndResetDailyCount(); // 자정 즉시 초기화

      // 2️⃣ 그 후 매일 자정마다 반복
      _dailyResetTimer = Timer.periodic(const Duration(days: 1), (_) {
        checkAndResetDailyCount();
      });
    });
  }

  Future<void> checkAndResetDailyCount() async {
    final today = todayKey();
    final lastReset = box.get('lastResetDate');

    if (lastReset != today) {
      await box.put('affirmationCount', 0);
      await box.put('lastResetDate', today);
      loadData(); // UI 갱신
    }
  }

  void loadData() {
    setState(() {
      currentAffirmation = box.get('currentAffirmation', defaultValue: '');
      count = box.get('affirmationCount', defaultValue: 0);
      favoriteList = List<String>.from(
        box.get('favoriteAffirmations', defaultValue: []),
      );
    });
  }

  Future<void> startAffirmation(String text) async {
    if (text.trim().isEmpty) return;

    if (text != currentAffirmation) {
      final result = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('확언 변경'),
          content: const Text('카운트를 초기화할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('reset'),
              child: const Text('확인'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('keep'),
              child: const Text('초기화 안함'),
            ),
          ],
        ),
      );

      if (result == 'reset') {
        await box.put('affirmationCount', 0);
      }
      await box.put('currentAffirmation', text);
      loadData();
    }

    Future.delayed(Duration.zero, () {
      FocusScope.of(context).unfocus();
    });
  }

  void incrementCount() {
    setState(() {
      count += 1;
    });
    box.put('affirmationCount', count);

    final statsBox = Hive.box('affirmationStats');
    final today = todayKey();
    final data = Map<String, int>.from(statsBox.get(today, defaultValue: {}));

    data[currentAffirmation] = (data[currentAffirmation] ?? 0) + 1;
    statsBox.put(today, data);
  }

  void toggleFavorite(String text) {
    if (text.trim().isEmpty) return;

    if (favoriteList.contains(text)) {
      favoriteList.remove(text);
    } else {
      favoriteList.add(text);
    }

    box.put('favoriteAffirmations', favoriteList);
    setState(() {});
  }

  void showFavoriteModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder( // ✅ 여기!
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15), // 위쪽만 둥글게
        ),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('저장한 확언', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: favoriteList.isEmpty
                    ? const Center(child: Text('저장된 확언이 없습니다.'))
                    : ListView.builder(
                  itemCount: favoriteList.length,
                  itemBuilder: (context, index) {
                    final item = favoriteList[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 24, right: 16),
                      title: Text(item),
                      onTap: () {
                        Navigator.of(context).pop();
                        _controller.text = item;
                        startAffirmation(item);
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          toggleFavorite(item);
                          Navigator.of(context).pop();
                          showFavoriteModal();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('확언'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: '통계 보기',
            onPressed: () => Navigator.pushNamed(context, '/affirmationStats'),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final topSpacing = constraints.maxHeight * 0.25;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: topSpacing),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: '확언을 입력하세요',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    favoriteList.contains(_controller.text.trim())
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: favoriteList.contains(_controller.text.trim())
                                        ? Colors.amber
                                        : Colors.grey,
                                  ),
                                  onPressed: () => toggleFavorite(_controller.text.trim()),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 80, maxWidth: 100),
                            child: ElevatedButton(
                              onPressed: () => startAffirmation(_controller.text.trim()),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: const Text('시작'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (currentAffirmation.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: ElevatedButton(
                          onPressed: incrementCount,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 80),
                          ),
                          child: Text(
                            currentAffirmation,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      '실행 횟수: $count회',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: showFavoriteModal,
                      child: Text(
                        '저장한 확언 보기',
                        style: TextStyle(fontSize: 16, color: Color(0xFF757575), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
