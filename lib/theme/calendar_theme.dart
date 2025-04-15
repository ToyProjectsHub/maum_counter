import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarTheme {
  static CalendarStyle calendarStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CalendarStyle(
      selectedDecoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : const Color(0xFFFFCC80),
        shape: BoxShape.circle,
      ),
      todayDecoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.grey[500]! : const Color(0xFFFFCC80),
          width: 1.2,
        ),
        shape: BoxShape.circle,
      ),
      todayTextStyle: TextStyle(
        color: isDark ? Colors.grey[100] : const Color(0xFF6D4C41),
        fontWeight: FontWeight.bold,
      ),
      markerDecoration: BoxDecoration(
        color: isDark ? Colors.grey[400] : const Color(0xFF6D4C41),
        shape: BoxShape.circle,
      ),
      defaultTextStyle: TextStyle(
        color: isDark ? Colors.grey[300] : Colors.brown[800],
      ),
      weekendTextStyle: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.brown[600],
      ),
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final markerColor = isDark ? Colors.grey[400]! : const Color(0xFF6D4C41);

        if (eventDays.any((d) => isSameDay(d, date))) {
          return Positioned(
            bottom: 10,
            child: Icon(
              Icons.circle,
              size: 6,
              color: markerColor,
            ),
          );
        }
        return null;
      },
    );
  }
}
