// Membaca alamat, kredensial, dan nama kanal broker dari berkas lingkungan.
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Nilai kosong atau bawaan menjaga aplikasi tetap dapat dimuat saat konfigurasi belum lengkap.
class AppConfig {
  String get mqttHost => dotenv.env['MQTT_HOST'] ?? '';
  String get stompHost => dotenv.env['STOMP_HOST'] ?? '';
  int get brokerPort {
    final port = int.tryParse(dotenv.env['BROKER_PORT'] ?? '');
    return port != null && port > 0 && port <= 65535 ? port : 443;
  }
  String get user => dotenv.env['BROKER_USER'] ?? '';
  String get password => dotenv.env['BROKER_PASSWORD'] ?? '';
  String get controlTopic => dotenv.env['CONTROL_TOPIC'] ?? 'control';
  String get sensorTopic => dotenv.env['SENSOR_TOPIC'] ?? 'sensor';
}
