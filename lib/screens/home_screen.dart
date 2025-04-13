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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final topSpacing = screenHeight * 0.25; // 💡 세로 위치 조절

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: topSpacing),

                    // ✅ 최대 너비 500으로 제한
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          buildMenuButton(context, '확언', '/affirmation'),
                          buildMenuButton(context, '호오포노포노', '/hooponopono'),
                          buildMenuButton(context, '릴리징', '/releasing'),
                          buildMenuButton(
                              context, '심플 홀리스틱 릴리징', '/simpleHolistic'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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