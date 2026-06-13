import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'color.dart';

Color getRandomColor() {
  List<Color> colors = [
    ColorApp.yellow,
    ColorApp.red,
    ColorApp.richLavender,
    ColorApp.oasisGreen,
    ColorApp.orange,
    Colors.white10,
  ];
  Random random = Random();
  return colors[random.nextInt(colors.length)];
}