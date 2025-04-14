import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarTheme {
  static CalendarStyle calendarStyle(BuildContext context) {
    return CalendarStyle(
      selectedDecoration: BoxDecoration(
        color: const Color(0xFFFFCC80),
        shape: BoxShape.circle,
      ),
      todayDecoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFFCC80), width: 1.2), // ✅ 오늘 날짜 테두리
        shape: BoxShape.circle,
      ),
      todayTextStyle: const TextStyle(
        color: Color(0xFF6D4C41),
        fontWeight: FontWeight.bold,
      ),
      markerDecoration: const BoxDecoration(
        color: Color(0xFF6D4C41),
        shape: BoxShape.circle,
      ),
      defaultTextStyle: TextStyle(color: Colors.brown[800]),
      weekendTextStyle: TextStyle(color: Colors.brown[600]),
    );
  }

  static HeaderStyle headerStyle() {
    return const HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
    );
  }

  static CalendarBuilders calendarBuilders(List<DateTime> eventDays) {
    return CalendarBuilders(
      markerBuilder: (context, date, events) {
        if (eventDays.any((d) => isSameDay(d, date))) {
          return const Positioned(
            bottom: 10,
            child: Icon(
              Icons.circle,
              size: 6,
              color: Color(0xFF6D4C41),
            ),
          );
        }
        return null;
      },
    );
  }
}
