// Titik masuk aplikasi: muat konfigurasi sebelum menampilkan dashboard.
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/app_config.dart';
import 'services/robot_io_service.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'views/dashboard_view.dart';
import 'views/splash_screen.dart';
import 'views/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RemoteControlApp());
}

// Akar aplikasi yang menampilkan splash sampai konfigurasi siap.
class RemoteControlApp extends StatefulWidget {
  const RemoteControlApp({super.key, this.autoConnect = true});

  final bool autoConnect;

  @override
  State<RemoteControlApp> createState() => _RemoteControlAppState();
}

class _RemoteControlAppState extends State<RemoteControlApp> {
  late final Future<void> _startup = _loadConfiguration();

  // Beri waktu agar identitas splash terlihat, sekaligus muat kredensial lokal.
  Future<void> _loadConfiguration() async {
    await Future.wait([
      dotenv.load(fileName: '.env'),
      Future<void>.delayed(const Duration(milliseconds: 1400)),
    ]);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Megabot-Peoplebot Control',
    theme: AppTheme.data,
    home: FutureBuilder<void>(
      future: _startup,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SplashScreen();
        }
        if (snapshot.hasError) {
          return SplashScreen(errorMessage: 'Konfigurasi .env gagal dimuat.');
        }
        return Dashboard(
          viewModel: DashboardViewModel(
            RobotIoService(),
            AppConfig(),
            autoConnect: widget.autoConnect,
          ),
        );
      },
    ),
  );
}
