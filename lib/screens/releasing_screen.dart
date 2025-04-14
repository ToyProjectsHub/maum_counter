import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ReleasingScreen extends StatefulWidget {
  const ReleasingScreen({super.key});

  @override
  State<ReleasingScreen> createState() => _ReleasingScreenState();
}

class _ReleasingScreenState extends State<ReleasingScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> questionTemplates = [
    '나는 {topic}을/를 허용할 수 있나요?',
    '나는 {topic}을/를 흘려보낼 수 있나요?',
    '나는 {topic}을/를 흘려보내고 싶나요?',
    '언제요?'
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
    box = Hive.box('releasingBox');
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

      // ✅ UI에 반영
      if (mounted) {
        setState(() {
          count = 0;
        });
      }
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
                  FocusScope.of(context).unfocus();
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
                  FocusScope.of(context).unfocus();
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

        final statsBox = Hive.box('releasingStats');
        final today = todayKey();
        final data = Map<String, int>.from(statsBox.get(today, defaultValue: {}));
        data[currentTopic] = (data[currentTopic] ?? 0) + 1;
        statsBox.put(today, data);

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
        style: TextStyle(color: Colors.blue),
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
        title: const Text('릴리징'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: '통계 보기',
            onPressed: () => Navigator.pushNamed(context, '/releasingStats'),
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
                if (currentQuestionIndex >= 0) buildQuestionCard(),
                const SizedBox(height: 30),
                Text(
                  '실행 횟수: $count회',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQuestionCard() {
    if (currentQuestionIndex < 0 || currentQuestionIndex >= questionTemplates.length) {
      return const SizedBox.shrink();
    }

    final rawQuestion = questionTemplates[currentQuestionIndex];
    final question = rawQuestion.replaceAll('{topic}', currentTopic);

    final answers = currentQuestionIndex < 3
        ? ['네', '아니오']
        : ['지금', '나중에'];

    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            children: buildColoredQuestion(question),
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500), // ✅ 버튼 영역 최대 너비 제한
          child: Row(
            children: answers.map((text) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    onPressed: () => handleAnswer(text),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 48), // 높이 고정
                    ),
                    child: Text(text),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
