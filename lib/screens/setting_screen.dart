import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:maum_counter/controller/theme_controller.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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

  final List<String> themeLabels = ['시스템 설정', '라이트 테마', '다크 테마'];
  late String selectedTheme;

  @override
  void initState() {
    super.initState();
    selectedTheme = _mapThemeLabel(ThemeController.instance.getThemeLabel());
  }

  void updateTheme(String value) {
    setState(() {
      selectedTheme = value;
      ThemeController.instance.setThemeFromLabel(_mapThemeLabel(value, reverse: true));
    });
  }

  String _mapThemeLabel(String value, {bool reverse = false}) {
    if (reverse) {
      switch (value) {
        case '시스템 설정':
          return '시스템';
        case '라이트 테마':
          return '라이트';
        case '다크 테마':
          return '다크';
        default:
          return value;
      }
    } else {
      switch (value) {
        case '시스템':
          return '시스템 설정';
        case '라이트':
          return '라이트 테마';
        case '다크':
          return '다크 테마';
        default:
          return value;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputTheme = Theme.of(context).inputDecorationTheme;
    final borderColor = inputTheme.enabledBorder?.borderSide.color ?? Colors.grey;
    final fillColor = inputTheme.fillColor ?? Theme.of(context).canvasColor;

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text('테마 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                value: selectedTheme,
                items: themeLabels.map((label) {
                  return DropdownMenuItem<String>(
                    value: label,
                    child: Text(label, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) updateTheme(value);
                },
                buttonStyleData: ButtonStyleData(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: fillColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 180,
                  offset: const Offset(0, 5),
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.arrow_drop_down),
                ),
              ),
            ),

            const SizedBox(height: 24),
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
      await Share.shareXFiles([XFile(file.path)], text: '마음 카운터 백업 파일');

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
    final result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.single.path!;
    final file = File(filePath);

    if (!filePath.toLowerCase().endsWith('.json')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 백업 파일 (.json)을 선택해주세요.')),
      );
      return;
    }

    try {
      final contents = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(contents);

      for (final boxName in data.keys) {
        if (boxNames.contains(boxName)) {
          final box = Hive.box(boxName);
          final Map<String, dynamic> entries = Map<String, dynamic>.from(data[boxName]);
          await box.clear();
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
