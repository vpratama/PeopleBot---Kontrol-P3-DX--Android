// Menjadi sumber status dashboard dan penghubung tampilan dengan layanan perangkat.
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../models/robot_command.dart';
import '../services/gamepad_service.dart';
import '../services/robot_io_service.dart';

// Mengelola data sensor, log, kecepatan, dan perintah yang diamati antarmuka.
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this.io, this.config, {this.autoConnect = true}) {
    io.onStatus = addLog;
    io.onSensorData = (values) {
      sensors = values;
      notifyListeners();
    };
    gamepad.onStatus = addLog;
    gamepad.onSpeed = _setControllerSpeed;
    gamepad.onCommand = (left, right) => publish(RobotCommand(left, right));
    gamepad.start();
    if (autoConnect) io.connect(config);
    addLog(
      'Ready. Supported controllers: DInput, XInput/Xbox, PlayStation, Nintendo Switch.',
    );
  }
  final RobotIoService io;
  final GamepadService gamepad = GamepadService();
  final AppConfig config;
  final bool autoConnect;
  List<int> sensors = List<int>.filled(8, 0);
  List<String> logs = [];
  int speed = 100;
  RobotCommand command = const RobotCommand(0, 0);

  // Simpan waktu pada pesan dan batasi riwayat agar tetap ringkas.
  void addLog(String message) {
    logs = [
      ...logs,
      '${DateTime.now().toIso8601String().substring(11, 19)}  $message',
    ];
    if (logs.length > 100) logs = logs.sublist(logs.length - 100);
    notifyListeners();
  }

  void setSpeed(int value) {
    speed = value.clamp(0, 400).toInt();
    gamepad.setSpeed(speed);
    notifyListeners();
  }

  // The gamepad service has already selected this speed before notifying us.
  void _setControllerSpeed(int value) {
    speed = value.clamp(0, 400).toInt();
    notifyListeners();
  }

  // Terjemahkan arah joystick ke nilai motor berdasarkan kecepatan terpilih.
  void drive(String direction) {
    var left = 0;
    var right = 0;
    if (direction == 'forward') left = right = speed;
    if (direction == 'backward') left = right = -speed;
    if (direction == 'left') left = speed;
    if (direction == 'right') right = speed;
    publish(RobotCommand(left, right));
  }

  // Perbarui tampilan terlebih dahulu, lalu teruskan perintah ke layanan I/O.
  void publish(RobotCommand value) {
    command = value;
    notifyListeners();
    io.publish(value.left, value.right, config);
  }

  void onDetached() => io.disconnect();
  @override
  void dispose() {
    gamepad.dispose();
    io.dispose();
    super.dispose();
  }
}
