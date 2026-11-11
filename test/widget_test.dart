// Memastikan dashboard dapat dibangun pada ukuran layar lebar dan ponsel.
import 'package:flutter/material.dart';
// Berkas ini menguji perilaku dasar widget Flutter.
// WidgetTester dapat dipakai untuk mengirim gestur, membaca teks, dan memeriksa widget.

import 'package:flutter_test/flutter_test.dart';

import 'package:remote_control_apk/main.dart';

// Jalankan pemeriksaan render pada dua ukuran layar representatif.
void main() {
  testWidgets('dashboard renders', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    await tester.pumpWidget(const RemoteControlApp(autoConnect: false));
    expect(find.text('Control'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('dashboard renders on mobile width', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    await tester.pumpWidget(const RemoteControlApp(autoConnect: false));
    expect(find.text('Control'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
