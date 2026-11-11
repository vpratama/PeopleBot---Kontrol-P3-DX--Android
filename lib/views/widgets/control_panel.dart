// Panel untuk menampilkan perintah motor, joystick, dan pengatur kecepatan.
import 'package:flutter/material.dart';

import '../../viewmodels/dashboard_viewmodel.dart';
import 'joystick_control.dart';
import 'panel.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key, required this.viewModel});
  final DashboardViewModel viewModel;
  @override
  Widget build(BuildContext context) => Panel(
    title: 'Control',
    child: Column(
      children: [
        Text(
          'Command: L=${viewModel.command.left} R=${viewModel.command.right}',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Center(
                  child: JoystickControl(onDirection: viewModel.drive),
                ),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Speed', style: TextStyle(fontSize: 10)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: viewModel.speed.toDouble(),
                            min: 0,
                            max: 400,
                            divisions: 16,
                            onChanged: (v) => viewModel.setSpeed(v.round()),
                          ),
                        ),
                        Text(
                          '${viewModel.speed}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Joystick / Gamepad: drive  |  release: stop',
            style: TextStyle(fontSize: 9),
          ),
        ),
      ],
    ),
  );
}
