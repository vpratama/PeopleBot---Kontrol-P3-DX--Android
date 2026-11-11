// Memetakan besar nilai sensor ke warna indikator radar.
import 'package:flutter/material.dart';

Color sensorColor(int value) => value < 500
    ? Colors.redAccent
    : value < 1500
    ? Colors.orangeAccent
    : value < 3000
    ? Colors.yellowAccent
    : Colors.greenAccent;
