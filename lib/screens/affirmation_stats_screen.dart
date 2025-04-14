import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AffirmationStatsScreen extends StatefulWidget {
  const AffirmationStatsScreen({super.key});

  @override
  State<AffirmationStatsScreen> createState() => _AffirmationStatsScreenState();
}

class _AffirmationStatsScreenState extends State<AffirmationStatsScreen> {
  DateTime selectedDate = DateTime.now();
  late Box statsBox;
  Map<String, int> statsForSelectedDay = {};

  @override
  void initState() {
    super.initState();
    statsBox = Hive.box('affirmationStats');
    loadStatsFor(selectedDate);
  }

  void loadStatsFor(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final data = statsBox.get(key, defaultValue: {});
    setState(() {
      selectedDate = date;
      statsForSelectedDay = Map<String, int>.from(data);
    });
  }

  List<DateTime> getEventDays() {
    final keys = statsBox.keys.cast<String>();
    return keys.map((key) => DateTime.parse(key).toLocal()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final eventDays = getEventDays();

    return Scaffold(
      appBar: AppBar(
        title: const Text('확언 통계'),
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
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: const Color(0xFFFFCC80), // 선택된 날짜 배경색
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFCC80), width: 1.2), // ✅ 오늘 날짜 테두리
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: Color(0xFF6D4C41), // ✅ 진한 브라운으로 명확히
                fontWeight: FontWeight.bold,
              ),
              markerDecoration: const BoxDecoration(
                color: Color(0xFF6D4C41), // 도트 마커 색상
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.brown[600]),
              defaultTextStyle: TextStyle(color: Colors.brown[800]),
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
                        color: Color(0xFF6D4C41),
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
            child: statsForSelectedDay.isEmpty
                ? const Center(
              child: Text(
                '해당 날짜에 실행한 확언이 없습니다.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              itemCount: statsForSelectedDay.length,
              itemBuilder: (context, index) {
                final entry = statsForSelectedDay.entries.elementAt(index);
                return ListTile(
                  title: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: Text(
                    '${entry.value}회',
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
