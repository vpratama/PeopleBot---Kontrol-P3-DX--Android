// Menampilkan log terbaru dari koneksi dan aktivitas aplikasi.
import 'package:flutter/material.dart';

import 'panel.dart';

class SystemLogPanel extends StatelessWidget {
  const SystemLogPanel({super.key, required this.logs});
  final List<String> logs;
  @override
  Widget build(BuildContext context) => Panel(
    title: 'SYSTEM LOG',
    child: ListView(
      children: logs.reversed
          .map((entry) => Text(entry, style: const TextStyle(fontSize: 10)))
          .toList(),
    ),
  );
}
