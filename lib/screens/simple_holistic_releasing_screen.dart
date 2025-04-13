import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class SimpleHolisticReleasingScreen extends StatefulWidget {
  const SimpleHolisticReleasingScreen({super.key});

  @override
  State<SimpleHolisticReleasingScreen> createState() => _SimpleHolisticReleasingScreenState();
}

class _SimpleHolisticReleasingScreenState extends State<SimpleHolisticReleasingScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> questionTemplates = [
    '나는 최대한 {topic}을/를 환영하도록 나를 허용할 수 있나요?',
    '나는 최대한 {topic}에 저항하도록 나를 허용할 수 있나요?',
  ];

  late Box box;
  String currentTopic = '';
  int currentQuestionIndex = -1;
  int count = 0;
  Timer? _resetTimer;

  String todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    box = Hive.box('simpleHolistic');
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
      await box.put('count', 0);
      await box.put('lastResetDate', today);
      loadData();
    }
  }

  void loadData() {
    setState(() {
      currentTopic = box.get('currentTopic', defaultValue: '');
      count = box.get('count', defaultValue: 0);
      _controller.text = currentTopic;
    });
  }

  void startTopic(String topic) {
    FocusScope.of(context).unfocus();

    if (topic.trim().isEmpty) return;

    if (topic != currentTopic) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('주제 변경'),
          content: const Text('카운트를 초기화할까요?'),
          actions: [
            TextButton(
              onPressed: () {
                box.put('currentTopic', topic);
                box.put('count', 0);
                Navigator.of(ctx).pop();
                loadData();

                Future.delayed(Duration.zero, () {
                  FocusScope.of(context).unfocus(); // ✅ 다시 한 번 포커스 해제
                });

                setState(() {
                  currentQuestionIndex = 0;
                });
              },
              child: const Text('확인'),
            ),
            TextButton(
              onPressed: () {
                box.put('currentTopic', topic);
                Navigator.of(ctx).pop();
                loadData();

                Future.delayed(Duration.zero, () {
                  FocusScope.of(context).unfocus(); // ✅ 다시 한 번 포커스 해제
                });

                setState(() {
                  currentQuestionIndex = 0;
                });
              },
              child: const Text('초기화 안함'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        currentQuestionIndex = 0;
      });
    }
  }

  void handleAnswer(String answer) {
    setState(() {
      currentQuestionIndex++;

      if (currentQuestionIndex >= questionTemplates.length) {
        count += 1;
        box.put('count', count);

        final statsBox = Hive.box('simpleHolisticStats');
        final today = todayKey();
        final data = Map<String, int>.from(statsBox.get(today, defaultValue: {}));
        data[currentTopic] = (data[currentTopic] ?? 0) + 1;
        statsBox.put(today, data);

        // ✅ 다음 프레임에서 0으로 리셋 (UI 안전)
        Future.delayed(Duration.zero, () {
          if (mounted) {
            setState(() {
              currentQuestionIndex = 0;
            });
          }
        });
      }
    });
  }

  List<TextSpan> buildColoredQuestion(String fullText) {
    final topic = currentTopic;
    final start = fullText.indexOf(topic);
    if (start == -1) {
      return [TextSpan(text: fullText)];
    }

    return [
      TextSpan(text: fullText.substring(0, start)),
      TextSpan(
        text: topic,
        style: const TextStyle(color: Colors.blue),
      ),
      TextSpan(text: fullText.substring(start + topic.length)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topSpacing = screenHeight * 0.25;

    return Scaffold(
      appBar: AppBar(
        title: const Text('심플 홀리스틱 릴리징'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: '통계 보기',
            onPressed: () => Navigator.pushNamed(context, '/simpleHolisticStats'),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
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
                            hintText: '주제를 입력하세요',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => startTopic(_controller.text.trim()),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('시작'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (currentQuestionIndex >= 0 &&
                    currentQuestionIndex < questionTemplates.length)
                  buildQuestionCard(),
                const SizedBox(height: 30),
                Text(
                  '실행 횟수: $count회',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQuestionCard() {
    // ✅ 범위 초과 방지
    if (currentQuestionIndex < 0 || currentQuestionIndex >= questionTemplates.length) {
      return const SizedBox.shrink();
    }

    final rawQuestion = questionTemplates[currentQuestionIndex];
    final question = rawQuestion.replaceAll('{topic}', currentTopic);

    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
            children: buildColoredQuestion(question),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['네', '아니오'].map((text) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: () => handleAnswer(text),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(text),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
