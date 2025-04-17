import 'package:flutter/material.dart';

class WinLinePainter extends CustomPainter {
  final List<int> pattern;
  const WinLinePainter(this.pattern);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.red.withValues(alpha: 0.8)
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    // Compute cell centers:
    final cellW = size.width / 3;
    final cellH = size.height / 3;
    Offset center(int idx) {
      final row = idx ~/ 3;
      final col = idx % 3;
      return Offset(col * cellW + cellW / 2, row * cellH + cellH / 2);
    }

    final p0 = center(pattern[0]);
    final p2 = center(pattern[2]);
    canvas.drawLine(p0, p2, paint);
  }

  @override
  bool shouldRepaint(covariant WinLinePainter old) => old.pattern != pattern;
}
