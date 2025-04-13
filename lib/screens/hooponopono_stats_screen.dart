import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class HooponoponoStatsScreen extends StatefulWidget {
  const HooponoponoStatsScreen({super.key});

  @override
  State<HooponoponoStatsScreen> createState() => _HooponoponopStatsScreenState();
}

class _HooponoponopStatsScreenState extends State<HooponoponoStatsScreen> {
  DateTime selectedDate = DateTime.now();
  late Box statsBox;
  int countForDay = 0;

  @override
  void initState() {
    super.initState();
    statsBox = Hive.box('hooponoponoStats');
    loadStatsFor(selectedDate);
  }

  void loadStatsFor(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final count = statsBox.get(key, defaultValue: 0);
    setState(() {
      selectedDate = date;
      countForDay = count;
    });
  }

  List<DateTime> getEventDays() {
    final keys = statsBox.keys.cast<String>();
    return keys.map((key) => DateTime.parse(key)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final eventDays = getEventDays();

    return Scaffold(
      appBar: AppBar(
        title: const Text('호오포노포노 통계'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2024, 1, 1),
            lastDay: DateTime(2999, 12, 31),
            focusedDay: selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, selectedDate),
            onDaySelected: (selectedDay, _) => loadStatsFor(selectedDay),
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (eventDays.any((d) => isSameDay(d, date))) {
                  return Positioned(
                    bottom: 10,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat('yyyy.MM.dd').format(selectedDate),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: countForDay == 0
                ? const Center(
              child: Text(
                '해당 날짜에 실행한 기록이 없습니다.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
                : ListView(
              children: [
                ListTile(
                  title: const Text(
                    '실행 횟수',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: Text(
                    '$countForDay회',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}