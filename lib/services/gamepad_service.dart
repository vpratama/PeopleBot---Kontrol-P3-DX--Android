// Membaca masukan gamepad, lalu meneruskannya langsung sebagai perintah motor.
import 'dart:async';

import 'package:gamepads/gamepads.dart';

class ControllerState {
  final buttons = <GamepadButton>{};
  double leftX = 0;
  double leftY = 0;
}

class GamepadService {
  static const Map<GamepadButton, int> _speedByButton = {
    GamepadButton.x: 100,
    GamepadButton.y: 200,
    GamepadButton.b: 300,
    GamepadButton.a: 400,
  };

  final controllers = <String, ControllerState>{};
  StreamSubscription<NormalizedGamepadEvent>? eventsSubscription;
  StreamSubscription<GamepadConnectionEvent>? connectionSubscription;
  void Function(int left, int right)? onCommand;
  void Function(int speed)? onSpeed;
  void Function(String message)? onStatus;
  int speed = 100;
  bool _started = false;
  bool _disposed = false;

  // Start listening before listing devices so a connect event cannot be missed.
  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    connectionSubscription = Gamepads.connectionEvents.listen(
      _handleConnection,
    );
    eventsSubscription = Gamepads.normalizedEvents.listen(_handle);
    try {
      for (final controller in await Gamepads.list()) {
        _accept(controller.id, controller.name);
      }
    } catch (error) {
      onStatus?.call('Could not list gamepads: $error');
    }
  }

  void _handleConnection(GamepadConnectionEvent event) {
    if (_disposed) return;
    if (event.type == GamepadConnectionEventType.connected) {
      _accept(event.gamepadId, event.name);
      return;
    }
    if (controllers.remove(event.gamepadId) != null) {
      onStatus?.call('Controller disconnected: ${event.name}');
      onCommand?.call(0, 0);
    }
  }

  void _accept(String id, String name) {
    if (controllers.containsKey(id) || _disposed) return;
    controllers[id] = ControllerState();
    onStatus?.call('Controller connected: $name');
  }

  // Use normalized buttons/axes so Android key codes and controller labels
  // never need to be guessed or turned into simulated touchscreen taps.
  void _handle(NormalizedGamepadEvent event) {
    if (_disposed) return;
    final state = controllers[event.gamepadId];
    if (state == null) return;

    final button = event.button;
    if (button != null) {
      if (event.value > .5) {
        state.buttons.add(button);
        final selectedSpeed = _speedByButton[button];
        if (selectedSpeed != null && selectedSpeed != speed) {
          speed = selectedSpeed;
          onSpeed?.call(speed);
        }
      } else {
        state.buttons.remove(button);
      }
    }
    if (event.axis == GamepadAxis.leftStickX) state.leftX = event.value;
    if (event.axis == GamepadAxis.leftStickY) state.leftY = event.value;
    _publishCommand(state);
  }

  // Keep the pad's speed in sync with the touchscreen slider.
  void setSpeed(int value) {
    speed = value.clamp(0, 400).toInt();
    for (final state in controllers.values) {
      final command = _commandFor(state);
      if (command.$1 != 0 || command.$2 != 0) {
        onCommand?.call(command.$1, command.$2);
      }
    }
  }

  void _publishCommand(ControllerState state) {
    final command = _commandFor(state);
    onCommand?.call(command.$1, command.$2);
  }

  (int, int) _commandFor(ControllerState state) {
    final forward =
        state.buttons.contains(GamepadButton.dpadUp) || state.leftY > .2;
    final backward =
        state.buttons.contains(GamepadButton.dpadDown) || state.leftY < -.2;
    final left =
        state.buttons.contains(GamepadButton.dpadLeft) || state.leftX < -.2;
    final right =
        state.buttons.contains(GamepadButton.dpadRight) || state.leftX > .2;
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
    return (leftMotor, rightMotor);
  }

  void dispose() {
    _disposed = true;
    eventsSubscription?.cancel();
    connectionSubscription?.cancel();
  }
}
