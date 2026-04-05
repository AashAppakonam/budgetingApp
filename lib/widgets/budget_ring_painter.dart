import 'package:flutter/material.dart';
import 'dart:math';

class BudgetRingPainter extends CustomPainter {
  final List<Map<String, dynamic>> categorySpent;
  final double total;

  BudgetRingPainter({required this.categorySpent, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 20.0;
    Offset center = Offset(size.width / 2, size.height / 2);
    // Reduce radius to make room for emojis
    double radius = (size.width - strokeWidth) / 2 - 25;

    // Background Ring (Total Budget)
    Paint bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius, bgPaint);

    if (total <= 0) return;

    double currentAngle = -pi / 2; // Start at the top
    List<Rect> drawnRects = [];

    for (var catData in categorySpent) {
      final category = catData['category']; // Assuming ExpenseCategory
      final amount = catData['amount'] as double;
      final color = Color(category.colorValue);
      
      if (amount <= 0) continue;
      
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

      // Draw emoji if present
      if (category.emoji != null && category.emoji.isNotEmpty) {
        double midAngle = currentAngle + (sweepAngle / 2);
        double emojiRadius = radius + strokeWidth / 2 + 15; // outside the ring

        final textPainter = TextPainter(
          text: TextSpan(
            text: category.emoji,
            style: const TextStyle(fontSize: 18),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        bool isOverlapping;
        double x, y;
        Rect emojiRect;

        // Push emoji outwards until it no longer overlaps with drawn ones
        do {
          isOverlapping = false;
          x = center.dx + emojiRadius * cos(midAngle);
          y = center.dy + emojiRadius * sin(midAngle);
          
          emojiRect = Rect.fromCenter(
            center: Offset(x, y), 
            width: textPainter.width + 8, // slight padding
            height: textPainter.height + 8,
          );

          for (var rect in drawnRects) {
            if (emojiRect.overlaps(rect)) {
              isOverlapping = true;
              emojiRadius += 18; // Push outward
              break;
            }
          }
        } while (isOverlapping);

        drawnRects.add(emojiRect);

        canvas.translate(x, y);
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        canvas.translate(-x, -y);
      }

      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
