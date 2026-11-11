// Menampilkan peta OpenStreetMap dan posisi awal robot.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as geo;

import 'panel.dart';

class MapPanel extends StatelessWidget {
  const MapPanel({super.key});
  @override
  Widget build(BuildContext context) => Panel(
    title: 'MAP // ROBOT POSITION',
    child: FlutterMap(
      options: const MapOptions(
        initialCenter: geo.LatLng(-6.95360761453292, 107.6965409137443),
        initialZoom: 17,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'id.smartsystem.remote_control_apk',
        ),
        const MarkerLayer(
          markers: [
            Marker(
              point: geo.LatLng(-6.95360761453292, 107.6965409137443),
              width: 42,
              height: 42,
              child: Icon(Icons.location_on, size: 42, color: Colors.redAccent),
            ),
          ],
        ),
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    ),
  );
}
