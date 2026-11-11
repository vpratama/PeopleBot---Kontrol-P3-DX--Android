// Menyusun panel dashboard dan mengikat siklus hidup tampilan ke view model.
import 'package:flutter/material.dart';

import '../viewmodels/dashboard_viewmodel.dart';
import 'widgets/control_panel.dart';
import 'widgets/map_panel.dart';
import 'widgets/radar_panel.dart';
import 'widgets/system_log_panel.dart';

// Menerima view model agar panel-panel memakai status yang sama.
class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.viewModel});
  final DashboardViewModel viewModel;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.viewModel.addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  // Lepaskan koneksi ketika sistem menandai aplikasi akan ditutup.
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) widget.viewModel.onDetached();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.viewModel.removeListener(_changed);
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  // Susun peta dan kontrol di samping radar serta log sistem.
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (_, size) {
          final main = Expanded(
            flex: 6,
            child: Column(
              children: [
                const Expanded(child: MapPanel()),
                const SizedBox(height: 8),
                Expanded(child: ControlPanel(viewModel: widget.viewModel)),
              ],
            ),
          );
          final side = Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(child: RadarPanel(values: widget.viewModel.sensors)),
                const SizedBox(height: 12),
                Expanded(child: SystemLogPanel(logs: widget.viewModel.logs)),
              ],
            ),
          );
          final padding = EdgeInsets.fromLTRB(
            size.maxWidth * .05,
            12,
            size.maxWidth * .05,
            12,
          );
          return Padding(
            padding: padding,
            child: Row(children: [main, const SizedBox(width: 12), side]),
          );
        },
      ),
    ),
  );
}
