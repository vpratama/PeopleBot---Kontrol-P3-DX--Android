// Mengelola koneksi MQTT untuk sensor dan STOMP untuk perintah robot.
import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../config/app_config.dart';

// Callback pada layanan ini mengirim status dan pembacaan sensor ke dashboard.
class RobotIoService {
  MqttServerClient? mqtt;
  StompClient? stomp;
  Timer? retryTimer;
  AppConfig? lastConfig;
  bool connecting = false;
  bool stompStarted = false;
  bool disposed = false;
  void Function(String)? onStatus;
  void Function(List<int>)? onSensorData;

  // Hubungkan Web STOMP terlebih dahulu, lalu mulai koneksi MQTT setelah berhasil.
  Future<void> connect(AppConfig config) async {
    if (disposed || stompStarted) return;
    lastConfig = config;
    stompStarted = true;
    onStatus?.call('Connecting to Web STOMP...');
    _connectStomp(config);
  }

  Future<void> _connectMqtt(AppConfig config) async {
    if (disposed || connecting || stomp?.connected != true) return;
    if (mqtt?.connectionStatus?.state == MqttConnectionState.connected) return;
    connecting = true;
    onStatus?.call('Web STOMP connected; connecting to MQTT WebSocket...');
    final client =
        MqttServerClient.withPort(
            config.mqttHost,
            'remote-control-android',
            config.brokerPort,
          )
          ..keepAlivePeriod = 60
          ..useWebSocket = true
          ..websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    client.onDisconnected = () {
      if (!disposed) {
        onStatus?.call('MQTT disconnected; retrying...');
        scheduleRetry();
      }
    };
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier('remote-control-android')
        .startClean();
    if (config.user.isNotEmpty) {
      client.connectionMessage = client.connectionMessage!.authenticateAs(
        config.user,
        config.password,
      );
    }
    mqtt = client;
    try {
      await client.connect();
      if (disposed) {
        client.disconnect();
        connecting = false;
        return;
      }
      client.subscribe(config.sensorTopic, MqttQos.atMostOnce);
      onStatus?.call('SUBSCRIBE MQTT status: ${config.sensorTopic}');
      client.updates?.listen((events) {
        final message = events.first.payload as MqttPublishMessage;
        final values =
            MqttPublishPayload.bytesToStringAsString(message.payload.message)
                .split(',')
                .map((v) => double.tryParse(v.trim())?.round())
                .whereType<int>()
                .toList();
        if (values.length == 8) {
          onStatus?.call('SUBSCRIBE MQTT data: $values');
          onSensorData?.call(values);
        }
      });
      onStatus?.call('MQTT WebSocket connected');
      retryTimer?.cancel();
    } catch (error) {
      if (!disposed) {
        onStatus?.call('MQTT WebSocket error: $error');
        scheduleRetry();
      }
    }
    connecting = false;
  }

  // Jadwalkan percobaan ulang tunggal setelah koneksi terputus.
  void scheduleRetry() {
    if (disposed || lastConfig == null || retryTimer?.isActive == true) return;
    retryTimer = Timer(
      const Duration(seconds: 5),
      () => _connectMqtt(lastConfig!),
    );
  }

  // Siapkan koneksi Web STOMP dengan kredensial dan pemulihan otomatis.
  void _connectStomp(AppConfig config) {
    if (disposed) return;
    stomp = StompClient(
      config: StompConfig(
        url: config.stompHost,
        reconnectDelay: const Duration(seconds: 5),
        stompConnectHeaders: {
          'login': config.user,
          'passcode': config.password,
          'host': '/',
        },
        onConnect: (_) {
          onStatus?.call('Web STOMP connected');
          _connectMqtt(config);
        },
        onStompError: (frame) =>
            onStatus?.call('Web STOMP error: ${frame.body ?? frame.headers}'),
        onWebSocketError: (error) =>
            onStatus?.call('Web STOMP socket error: $error'),
        onWebSocketDone: () => onStatus?.call('Web STOMP disconnected'),
      ),
    )..activate();
  }

  // Kirim pasangan kecepatan motor ke antrean kontrol jika STOMP tersambung.
  void publish(int left, int right, AppConfig config) {
    final message = '$left,$right';
    if (stomp?.connected == true) {
      stomp!.send(destination: '/queue/${config.controlTopic}', body: message);
      onStatus?.call('PUBLISH STOMP status: sent');
      onStatus?.call('PUBLISH STOMP data: $message');
    } else {
      onStatus?.call('PUBLISH STOMP status: skipped (disconnected)');
    }
  }

  // Putuskan koneksi dan cegah percobaan ulang saat aplikasi ditutup.
  void disconnect() {
    disposed = true;
    retryTimer?.cancel();
    mqtt?.disconnect();
    stomp?.deactivate();
  }

  void dispose() {
    disposed = true;
    retryTimer?.cancel();
  }
}
