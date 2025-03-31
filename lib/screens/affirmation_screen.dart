import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AffirmationScreen extends StatefulWidget {
  const AffirmationScreen({super.key});

  @override
  State<AffirmationScreen> createState() => _AffirmationScreenState();
}

class _AffirmationScreenState extends State<AffirmationScreen> {
  final TextEditingController _controller = TextEditingController();
  late Box box;

  String currentAffirmation = '';
  int count = 0;
  List<String> favoriteList = [];

  @override
  void initState() {
    super.initState();
    box = Hive.box('affirmationBox');
    loadData();
  }

  void loadData() {
    setState(() {
      currentAffirmation = box.get('currentAffirmation', defaultValue: '');
      count = box.get('affirmationCount', defaultValue: 0);
      favoriteList =
      List<String>.from(box.get('favoriteAffirmations', defaultValue: []));
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
              onPressed: () {
                Navigator.of(ctx).pop('reset');
              },
              child: const Text('확인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop('keep');
              },
              child: const Text('초기화 안함'),
            ),
          ],
        ),
      );

      // ✅ 처리 후 상태 반영
      if (result == 'reset') {
        box.put('currentAffirmation', text);
        box.put('affirmationCount', 0);
      } else if (result == 'keep') {
        box.put('currentAffirmation', text);
      }

      loadData();
    }

    // ✅ dialog 이후 확실히 포커스 제거
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).unfocus();
    });
  }


  void incrementCount() {
    setState(() {
      count += 1;
    });
    box.put('affirmationCount', count);
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
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '저장한 확언',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: favoriteList.isEmpty
                    ? const Center(child: Text('저장된 확언이 없습니다.'))
                    : ListView.builder(
                  itemCount: favoriteList.length,
                  itemBuilder: (context, index) {
                    final item = favoriteList[index];
                    return ListTile(
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
    final trimmedText = _controller.text.trim();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('확언'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final topSpacing = screenHeight * 0.3;

            return SingleChildScrollView(
              child: Padding(
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
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      favoriteList.contains(trimmedText)
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: favoriteList.contains(trimmedText)
                                          ? Colors.amber
                                          : Colors.grey,
                                    ),
                                    onPressed: () => toggleFavorite(
                                        _controller.text.trim()),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 80,
                                maxWidth: 100,
                              ),
                              child: ElevatedButton(
                                onPressed: () => startAffirmation(
                                    _controller.text.trim()),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
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
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              currentAffirmation,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),
                      Text(
                        '실행 횟수: $count',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: showFavoriteModal,
                        child: const Text(
                          '저장한 확언 보기',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
