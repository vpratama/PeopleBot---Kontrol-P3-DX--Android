// Menemukan gamepad, menafsirkan masukan, lalu mengubahnya menjadi perintah motor.
import 'dart:async';

import 'package:gamepads/gamepads.dart';

// Jenis kontroler dipakai untuk menyesuaikan pemetaan tombol kecepatannya.
enum ControllerType { dinput, xbox, playstation, nintendoSwitch }

// Menyimpan tombol, stik, dan kecepatan terakhir untuk satu kontroler.
class ControllerState {
  ControllerState(this.type);
  final ControllerType type;
  final buttons = <GamepadButton>{};
  int selectedSpeed = 100;
  double leftX = 0;
  double leftY = 0;
}

// Callback meneruskan perintah, kecepatan, dan status ke view model.
class GamepadService {
  final controllers = <String, ControllerState>{};
  StreamSubscription<NormalizedGamepadEvent>? eventsSubscription;
  StreamSubscription<GamepadConnectionEvent>? connectionSubscription;
  void Function(int left, int right)? onCommand;
  void Function(int speed)? onSpeed;
  void Function(String message)? onStatus;

  // Daftarkan kontroler yang sudah terhubung dan dengarkan perubahan berikutnya.
  Future<void> start() async {
    for (final controller in await Gamepads.list()) {
      _accept(controller.id, controller.name);
    }
    connectionSubscription = Gamepads.connectionEvents.listen((event) {
      if (event.type == GamepadConnectionEventType.connected) {
        _accept(event.gamepadId, event.name);
      }
      if (event.type == GamepadConnectionEventType.disconnected) {
        controllers.remove(event.gamepadId);
      }
    });
    eventsSubscription = Gamepads.normalizedEvents.listen(_handle);
  }

  // Perbarui tombol atau sumbu stik, lalu hitung ulang perintah motor.
  void _handle(NormalizedGamepadEvent event) {
    final state = controllers[event.gamepadId];
    if (state == null) return;
    if (event.button != null) {
      if (event.value > .5) {
        state.buttons.add(event.button!);
        _updateSpeed(state, event.button!, event.rawEvent.key);
      } else {
        state.buttons.remove(event.button!);
      }
    }
    if (event.axis == GamepadAxis.leftStickX) {
      state.leftX = event.value;
    }
    if (event.axis == GamepadAxis.leftStickY) {
      state.leftY = event.value;
    }
    _publishCommand(state);
  }

  // Kenali jenis kontroler dan buat status awal untuk perangkat tersebut.
  void _accept(String id, String name) {
    final normalized = name.toLowerCase();
    final type = normalized.contains('xinput') || normalized.contains('xbox')
        ? ControllerType.xbox
        : normalized.contains('playstation') ||
              normalized.contains('dualshock') ||
              normalized.contains('dualsense') ||
              normalized.contains('ps4') ||
              normalized.contains('ps5')
        ? ControllerType.playstation
        : normalized.contains('nintendo') ||
              normalized.contains('switch') ||
              normalized.contains('joy-con')
        ? ControllerType.nintendoSwitch
        : ControllerType.dinput;
    controllers[id] = ControllerState(type);
    final transport =
        normalized.contains('bluetooth') ||
            normalized.contains('wireless') ||
            normalized.contains('joy-con')
        ? 'Bluetooth'
        : 'USB';
    onStatus?.call('Controller connected: $transport, ${_label(type)}, $name');
  }

  String _label(ControllerType type) => switch (type) {
    ControllerType.dinput => 'DInput',
    ControllerType.xbox => 'XInput/Xbox',
    ControllerType.playstation => 'PlayStation',
    ControllerType.nintendoSwitch => 'Nintendo Switch',
  };

  void _updateSpeed(
    ControllerState state,
    GamepadButton button,
    String rawKey,
  ) {
    final normalizedKey = rawKey.toLowerCase().trim();
    final dinputButton = int.tryParse(
      normalizedKey.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    final value = state.type == ControllerType.dinput
        ? _dinputSpeed(dinputButton, normalizedKey)
        : switch (state.type) {
            ControllerType.nintendoSwitch => {
              GamepadButton.x: 100,
              GamepadButton.y: 200,
              GamepadButton.a: 300,
              GamepadButton.b: 400,
            }[button],
            _ => {
              GamepadButton.x: 100,
              GamepadButton.y: 200,
              GamepadButton.b: 300,
              GamepadButton.a: 400,
            }[button],
          };
    if (value != null) {
      state.selectedSpeed = value;
      onSpeed?.call(value);
    }
  }

  int? _dinputSpeed(int? buttonIndex, String rawKey) {
    final indexed = {0: 100, 1: 200, 2: 300, 3: 400}[buttonIndex];
    if (indexed != null) return indexed;
    return {'x': 100, 'y': 200, 'b': 300, 'a': 400}[rawKey];
  }

  // Gabungkan masukan arah menjadi nilai motor kiri dan kanan.
  void _publishCommand(ControllerState state) {
    final forward =
        state.buttons.contains(GamepadButton.dpadUp) || state.leftY > .2;
    final backward =
        state.buttons.contains(GamepadButton.dpadDown) || state.leftY < -.2;
    final left =
        state.buttons.contains(GamepadButton.dpadLeft) || state.leftX < -.2;
    final right =
        state.buttons.contains(GamepadButton.dpadRight) || state.leftX > .2;
    final speed = state.selectedSpeed;
    var leftMotor = 0;
    var rightMotor = 0;
    if (forward && !backward) {
      if (left && !right) {
        leftMotor = speed;
      } else if (right && !left) {
        rightMotor = speed;
      } else {
        leftMotor = rightMotor = speed;
      }
    } else if (backward && !forward) {
      if (left && !right) {
        leftMotor = -speed;
      } else if (right && !left) {
        rightMotor = -speed;
      } else {
        leftMotor = rightMotor = -speed;
      }
    } else if (left && !right) {
      leftMotor = speed;
    } else if (right && !left) {
      rightMotor = speed;
    }
    onCommand?.call(leftMotor, rightMotor);
  }

  // Hentikan langganan stream agar tidak ada event setelah layar ditutup.
  void dispose() {
    eventsSubscription?.cancel();
    connectionSubscription?.cancel();
  }
}
