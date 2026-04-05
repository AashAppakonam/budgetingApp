import 'package:flutter/material.dart';
import 'dart:math';

class BudgetRingPainter extends CustomPainter {
  final Map<Color, double> categorySpent;
  final double total;

  BudgetRingPainter({required this.categorySpent, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 20.0;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = (size.width - strokeWidth) / 2;

    // Background Ring (Total Budget)
    Paint bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius, bgPaint);

    if (total <= 0) return;

    double currentAngle = -pi / 2; // Start at the top

    categorySpent.forEach((color, amount) {
      if (amount <= 0) return;
      
      double spentPercentage = (amount / total).clamp(0.0, 1.0);
      double sweepAngle = 2 * pi * spentPercentage;

      Paint fgPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweepAngle,
        false,
        fgPaint,
      );

      currentAngle += sweepAngle;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
