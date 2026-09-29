import 'package:flutter/material.dart';

class InvertedTopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const cornerRadius = 15.0;
    const curveDepth = 20.0;
    final centerX = size.width / 2;
    final curveHalfWidth = size.width * 0.46;

    return Path()
      ..moveTo(2, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..lineTo(centerX - curveHalfWidth, 0)
      ..quadraticBezierTo(centerX, curveDepth * 2, centerX + curveHalfWidth, 0)
      ..lineTo(size.width - cornerRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, cornerRadius)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
