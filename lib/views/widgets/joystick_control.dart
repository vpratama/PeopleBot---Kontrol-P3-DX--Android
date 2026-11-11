// Menggambar joystick sentuh dan menerjemahkan gerakannya menjadi arah.
import 'dart:math' as math;

import 'package:flutter/material.dart';

// Memancarkan arah selama pengguna menggerakkan kenop sentuh.
class JoystickControl extends StatefulWidget {
  const JoystickControl({super.key, required this.onDirection});
  final void Function(String direction) onDirection;
  @override
  State<JoystickControl> createState() => _JoystickControlState();
}

class _JoystickControlState extends State<JoystickControl> {
  Offset knob = Offset.zero;
  // Batasi gerakan ke dalam lingkaran lalu pilih arah dominan.
  void update(Offset position, Size size) {
    final center = size.center(Offset.zero);
    final delta = position - center;
    final radius = math.min(size.width, size.height) * .32;
    final distance = delta.distance;
    final limited = distance > radius ? delta / distance * radius : delta;
    setState(() => knob = limited);
    final h = limited.dx.abs() / radius;
    final v = limited.dy.abs() / radius;
    if (math.max(h, v) < .25) {
      widget.onDirection('stop');
    } else if (v >= h) {
      widget.onDirection(limited.dy < 0 ? 'forward' : 'backward');
    } else {
      widget.onDirection(limited.dx < 0 ? 'left' : 'right');
    }
  }

  void reset() {
    setState(() => knob = Offset.zero);
    widget.onDirection('stop');
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Touch joystick',
    child: SizedBox(
      width: 120,
      height: 120,
      child: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          onPanStart: (d) => update(d.localPosition, constraints.biggest),
          onPanUpdate: (d) => update(d.localPosition, constraints.biggest),
          onPanEnd: (_) => reset(),
          onPanCancel: reset,
          child: CustomPaint(painter: JoystickPainter(knob)),
        ),
      ),
    ),
  );
}

// Menggambar alas dan kenop joystick pada kanvas.
class JoystickPainter extends CustomPainter {
  JoystickPainter(this.knob);
  final Offset knob;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = math.min(size.width, size.height) * .42;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xff526568));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xff263a3c),
    );
    canvas.drawCircle(
      c,
      r * .68,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xff9aa9aa),
    );
    final k = c + knob;
    canvas.drawCircle(k, r * .34, Paint()..color = const Color(0xff263a3c));
    canvas.drawCircle(
      k,
      r * .34,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white70,
    );
  }

  @override
  bool shouldRepaint(JoystickPainter old) => old.knob != knob;
}
