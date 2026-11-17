import 'package:flutter/material.dart';

class InvertedTopCurveClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double curveDepth;
  final double centerX;
  final double curveHalfWidth;

  const InvertedTopCurveClipper({
    this.cornerRadius = 15.0,
    this.curveDepth = 20.0,
    this.centerX = 0.5,
    this.curveHalfWidth = 0.42,
  });

  @override
  Path getClip(Size size) {
    final curveCenterX = size.width * centerX;
    final curveHalfWidthPixels = size.width * curveHalfWidth;

    return Path()
      ..moveTo(2, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..lineTo(curveCenterX - curveHalfWidthPixels, 0)
      ..quadraticBezierTo(
        curveCenterX,
        curveDepth * 2,
        curveCenterX + curveHalfWidthPixels,
        0,
      )
      ..lineTo(size.width - cornerRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, cornerRadius)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
