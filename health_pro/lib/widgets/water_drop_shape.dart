import 'package:flutter/material.dart';

class WaterDropShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..cubicTo(
        size.width * 0.999,
        size.height * 0.99,
        size.width,
        size.height * 0.7,
        size.width / 2,
        0,
      )
      ..cubicTo(
        0,
        size.height * 0.7,
        size.width * 0.001,
        size.height * 0.99,
        size.width / 2,
        size.height,
      )
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
