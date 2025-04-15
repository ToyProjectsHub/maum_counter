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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.brown, width: 1), // ✅ 여기 추가
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

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: 'Pretendard',
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFBDBDBD),
        secondary: Color(0xFF90A4AE),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white70,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F1F1F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.grey, width: 1), // ✅ 여기 추가
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.white54, width: 2),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white70,
        selectionColor: Color(0xFF424242),
        selectionHandleColor: Colors.white70,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF424242),
          foregroundColor: Colors.white,
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
        backgroundColor: Color(0xFF1F1F1F),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Pretendard',
        ),
        contentTextStyle: TextStyle(
          fontSize: 16,
          color: Colors.white70,
          fontFamily: 'Pretendard',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[300],
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Pretendard',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
