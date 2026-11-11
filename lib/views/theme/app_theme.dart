// Menetapkan tema visual global aplikasi.
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get data =>
      ThemeData(useMaterial3: false, fontFamily: 'Arial').copyWith(
        scaffoldBackgroundColor: const Color(0xffd5d5d5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff008f75)),
      );
}
