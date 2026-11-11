// Wadah visual seragam untuk panel-panel dashboard.
import 'package:flutter/material.dart';

class Panel extends StatelessWidget {
  const Panel({super.key, required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xffdedede),
      border: Border.all(color: const Color(0xff909090)),
    ),
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(color: Colors.black, fontSize: 10)),
        const SizedBox(height: 6),
        Expanded(child: child),
      ],
    ),
  );
}
