// Menampilkan delapan pembacaan sensor sebagai label dan grafik radar.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/sensor_color.dart';
import 'panel.dart';

// Data sensor digunakan bersama untuk label dan bentuk radar.
class RadarPanel extends StatelessWidget {
  const RadarPanel({super.key, required this.values});
  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final sensorLabels = [
      for (var i = 0; i < 8; i++)
        Text(
          'S${i + 1}:${values[i]}',
          style: TextStyle(fontSize: 10, color: sensorColor(values[i])),
        ),
    ];
    return Panel(
      title: 'PROXIMITY RADAR',
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _RadarPainter(values),
              child: const SizedBox.expand(),
            ),
          ),
          Wrap(spacing: 7, children: sensorLabels),
        ],
      ),
    );
  }
}

// Menggambar kisi delapan arah dan poligon jangkauan sensor.
class _RadarPainter extends CustomPainter {
  _RadarPainter(this.values);
  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) * .35;
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xff31535a);
    for (var ring = 1; ring <= 3; ring++) {
      canvas.drawCircle(center, radius * ring / 3, grid);
    }
    final points = <Offset>[];
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        center,
        center + Offset(math.sin(angle) * radius, -math.cos(angle) * radius),
        grid,
      );
      final distance = math.min(values[i].clamp(0, 3000), 3000) / 3000;
      points.add(
        center +
            Offset(
              math.sin(angle) * radius * distance,
              -math.cos(angle) * radius * distance,
            ),
      );
    }
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, Paint()..color = const Color(0x6630cfc0));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.tealAccent,
    );
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) => oldDelegate.values != values;
}
