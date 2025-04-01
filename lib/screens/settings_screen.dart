import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box settingsBox;
  int resetHour = 0;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settingsBox');
    resetHour = settingsBox.get('resetHour', defaultValue: 0);
  }

  void saveResetHour(int hour) {
    setState(() {
      resetHour = hour;
      settingsBox.put('resetHour', hour);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('하루 시작 시간이 저장되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '하루의 시작 시간',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonHideUnderline(
              child: DropdownButton2<int>(
                value: resetHour,
                isExpanded: true,
                onChanged: (value) {
                  if (value != null) {
                    saveResetHour(value);
                  }
                },
                items: List.generate(
                  24,
                      (index) => DropdownMenuItem(
                    value: index,
                    child: Text('$index시'),
                  ),
                ),
                buttonStyleData: ButtonStyleData(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade400),
                    color: Colors.white,
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '※ 이 시각을 기준으로 하루가 시작되어 통계가 집계됩니다.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
