import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var box = Hive.box('affirmationBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('마음 카운터'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // 데이터 저장 예제
                await box.put('testKey', 'Hello Hive!');

                // 데이터 로드 예제
                var value = box.get('testKey');
                print(value); // 콘솔에 'Hello Hive!' 출력됨
              },
              child: const Text('Hive 저장 및 로드 테스트'),
            ),
            const SizedBox(height: 20),
            buildMenuButton(context, '확언', '/affirmation'),
            buildMenuButton(context, '호오포노포노', '/hooponopono'),
            buildMenuButton(context, '릴리징', '/releasing'),
            buildMenuButton(context, '심플 홀리스틱 릴리징', '/holistic'),
          ],
        ),
      ),
    );
  }

  Widget buildMenuButton(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          backgroundColor: Colors.blue.shade100,
          elevation: 2,
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
    );
  }
}
