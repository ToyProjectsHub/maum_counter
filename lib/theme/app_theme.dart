import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFFDF6EC),
      fontFamily: 'Pretendard',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.brown),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFF3E0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.brown),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Color(0xFF6D4C41), width: 2),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFF6D4C41),
        selectionColor: Color(0xFFEFEBE9),
        selectionHandleColor: Color(0xFF6D4C41),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFCC80),
          foregroundColor: Colors.brown[800],
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Pretendard',
          ),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: Color(0xFFFFF3E0),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Pretendard',
          color: Color(0xFF4E342E),
        ),
        contentTextStyle: TextStyle(
          fontSize: 16,
          fontFamily: 'Pretendard',
          color: Color(0xFF6D4C41),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF6D4C41),
          textStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder( // ✅ 여기에 추가
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFCC80),
        foregroundColor: Colors.brown[800],
        titleTextStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.brown,
        ),
        elevation: 1,
      ),
    );
  }
}
