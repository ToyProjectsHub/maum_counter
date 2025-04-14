import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  final List<String> boxNames = const [
    'affirmationBox',
    'hooponoponoBox',
    'releasingBox',
    'simpleHolisticBox',
    'fullHolisticBox',
    'affirmationStats',
    'hooponoponoStats',
    'releasingStats',
    'simpleHolisticStats',
    'fullHolisticStats',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text('데이터 백업 및 복원',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => exportBackup(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                '백업 파일 내보내기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => importBackup(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                '백업 파일 불러오기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> exportBackup(BuildContext context) async {
    final Map<String, dynamic> exportData = {};

    final boxNames = [
      'affirmationBox',
      'hooponoponoBox',
      'releasingBox',
      'simpleHolisticBox',
      'fullHolisticBox',
      'affirmationStats',
      'hooponoponoStats',
      'releasingStats',
      'simpleHolisticStats',
      'fullHolisticStats',
    ];

    for (final boxName in boxNames) {
      final box = Hive.box(boxName);
      exportData[boxName] = box.toMap();
    }

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    final now = DateTime.now();
    final fileName = 'maum_counter_backup_${now.toIso8601String().split('T').first}.json';

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonString);

    if (context.mounted) {
      // 공유창 띄우기
      await Share.shareXFiles([XFile(file.path)], text: '마음 카운터 백업 파일');

      // 사용자 안내 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '백업이 완료되었습니다!\n복원을 위해 다운로드 폴더나 구글 드라이브 등에 저장해 주세요.',
          ),
          duration: Duration(seconds: 5),
        ),
      );

    }
  }

  Future<void> importBackup(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // ✅ 모든 파일 보여주기 (json 제한 제거)
    );

    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.single.path!;
    final file = File(filePath);

    // ✅ 확장자 확인 (실수로 이미지 등 선택 방지)
    if (!filePath.toLowerCase().endsWith('.json')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 백업 파일 (.json)을 선택해주세요.')),
      );
      return;
    }

    try {
      final contents = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(contents);

      final validBoxNames = [
        'affirmationBox',
        'hooponoponoBox',
        'releasingBox',
        'simpleHolisticBox',
        'fullHolisticBox',
        'affirmationStats',
        'hooponoponoStats',
        'releasingStats',
        'simpleHolisticStats',
        'fullHolisticStats',
      ];

      for (final boxName in data.keys) {
        if (validBoxNames.contains(boxName)) {
          final box = Hive.box(boxName);
          final Map<String, dynamic> entries = Map<String, dynamic>.from(data[boxName]);
          await box.clear(); // 기존 내용 삭제
          for (final entry in entries.entries) {
            await box.put(entry.key, entry.value);
          }
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('백업 파일에서 데이터 복원 완료')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('복원 실패: $e')),
        );
      }
    }
  }
}
