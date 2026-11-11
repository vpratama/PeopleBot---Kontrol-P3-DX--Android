# Megabot-Peoplebot Control

Aplikasi Flutter dengan logo robot-gamepad pastel dan splash screen pemuatan. Aplikasi ini digunakan untuk memantau sensor dan mengendalikan robot secara jarak jauh melalui joystick layar, gamepad, serta RabbitMQ. Peta menggunakan ubin OpenStreetMap.

## Fitur

- Menampilkan splash screen berlogo dengan indikator pemuatan berputar.
- Menampilkan peta, penanda posisi robot, radar delapan sensor, dan log sistem.
- Mengirim perintah motor kiri dan kanan melalui RabbitMQ Web STOMP.
- Menerima data sensor melalui RabbitMQ Web MQTT.
- Mendukung gamepad DInput, XInput/Xbox, PlayStation, dan Nintendo Switch.
- Menyediakan joystick layar dan pengaturan kecepatan motor.

## Persyaratan

- Flutter dan Dart sesuai batas versi pada `pubspec.yaml`.
- Android Studio/Android SDK untuk menjalankan aplikasi Android.
- Broker RabbitMQ dengan plugin Web STOMP dan Web MQTT aktif serta endpoint WebSocket yang menggunakan TLS.

## Menyiapkan konfigurasi

1. Salin `.env.example` menjadi `.env` di direktori utama proyek.
2. Isi alamat broker dan kredensial yang sesuai. Jangan masukkan kredensial nyata ke repositori.

| Variabel | Keterangan | Contoh |
| --- | --- | --- |
| `MQTT_HOST` | URL WebSocket MQTT | `wss://broker.example/ws` |
| `STOMP_HOST` | URL WebSocket STOMP | `wss://broker.example/ws` |
| `BROKER_PORT` | Port broker | `443` |
| `BROKER_USER` | Nama pengguna RabbitMQ | `pengguna` |
| `BROKER_PASSWORD` | Kata sandi RabbitMQ | `kata-sandi` |
| `CONTROL_TOPIC` | Nama antrean perintah STOMP | `control` |
| `SENSOR_TOPIC` | Topik MQTT untuk data sensor | `sensor` |

Aplikasi mengirim pasangan nilai motor dalam format `kiri,kanan` ke `/queue/<CONTROL_TOPIC>`. Nilai sensor harus berupa delapan angka yang dipisahkan koma, misalnya `120,240,360,480,600,720,840,960`.

> Pastikan broker mengizinkan koneksi WebSocket TLS dari perangkat dan akun yang digunakan memiliki izin baca/tulis pada antrean serta topik tersebut.

## Menjalankan aplikasi

```bash
flutter pub get
flutter run
```

Untuk membuat APK Android:

```bash
flutter build apk
```

## Cara menggunakan

- Gerakkan joystick pada panel **Control** untuk mengirim arah; lepaskan joystick untuk menghentikan motor.
- Atur nilai kecepatan dengan slider. Rentang perintah adalah 0 sampai 400.
- Gamepad dapat mengendalikan arah dengan tombol arah atau stik kiri. Tombol muka memilih tingkat kecepatan.
- Panel radar menampilkan nilai delapan sensor. Warna berubah mengikuti rentang nilai sensor.
- Log sistem menampilkan status koneksi dan aktivitas kirim/terima data.

## Susunan kode

- `lib/config/`: membaca konfigurasi koneksi dari `.env`.
- `lib/models/`: model perintah motor.
- `lib/services/`: komunikasi RabbitMQ dan pembacaan gamepad.
- `lib/viewmodels/`: status dashboard dan koordinasi aksi pengguna.
- `lib/views/`: tampilan dashboard, panel, tema, dan komponen visual.
- `test/`: pengujian widget dasar.
- `android/`: konfigurasi aplikasi Android dan integrasi Flutter.
