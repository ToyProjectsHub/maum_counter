import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../theme/calendar_theme.dart';

class ReleasingStatsScreen extends StatefulWidget {
  const ReleasingStatsScreen({super.key});

  @override
  State<ReleasingStatsScreen> createState() => _ReleasingStatsScreenState();
}

class _ReleasingStatsScreenState extends State<ReleasingStatsScreen> {
  DateTime selectedDate = DateTime.now();
  late Box statsBox;
  Map<String, int> topicStatsForDay = {};

  @override
  void initState() {
    super.initState();
    statsBox = Hive.box('releasingStats');
    loadStatsFor(selectedDate);
  }

  void loadStatsFor(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final rawData = statsBox.get(key, defaultValue: {});
    setState(() {
      selectedDate = date;
      topicStatsForDay = Map<String, int>.from(rawData);
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
        title: const Text('릴리징 통계'),
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
            calendarStyle: CalendarTheme.calendarStyle(context),
            headerStyle: CalendarTheme.headerStyle(),
            calendarBuilders: CalendarTheme.calendarBuilders(eventDays),
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat('yyyy.MM.dd').format(selectedDate),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: topicStatsForDay.isEmpty
                ? const Center(
              child: Text(
                '해당 날짜에 실행한 기록이 없습니다.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              itemCount: topicStatsForDay.length,
              itemBuilder: (context, index) {
                final entry = topicStatsForDay.entries.elementAt(index);
                return ListTile(
                  title: Text(
                    entry.key,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: Text(
                    '${entry.value}회',
                    style: TextStyle(fontSize: 16),
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
