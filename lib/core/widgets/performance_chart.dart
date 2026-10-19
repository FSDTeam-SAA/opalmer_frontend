import 'package:flutter/material.dart';

/// Shows only measured assessment values; missing days remain gaps.
class PerformanceChart extends StatelessWidget {
  final List<dynamic> points;
  const PerformanceChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (!points.any((point) => point['percentage'] is num)) {
      return const Center(child: Text('No reviewed assessments for this period.'));
    }
    return CustomPaint(painter: _PerformancePainter(points));
  }
}

class _PerformancePainter extends CustomPainter {
  final List<dynamic> points;
  _PerformancePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    const left = 32.0;
    const top = 24.0;
    final width = size.width - left - 16;
    final height = size.height - top - 28;
    final text = TextPainter(textDirection: TextDirection.ltr);
    void label(String value, Offset offset, {Color color = Colors.grey}) {
      text.text = TextSpan(text: value, style: TextStyle(color: color, fontSize: 10));
      text.layout();
      text.paint(canvas, offset);
    }
    for (var value = 0; value <= 100; value += 20) {
      final y = top + height * (1 - value / 100);
      canvas.drawLine(Offset(left, y), Offset(left + width, y), Paint()..color = const Color(0xFFE5E7EB));
      label('$value', Offset(0, y - 6));
    }
    final ink = Paint()..color = const Color(0xFF871DAD)..strokeWidth = 2;
    Offset? previous;
    final labelStep = (points.length / 7).ceil().clamp(1, 100);
    for (var i = 0; i < points.length; i++) {
      final x = left + (points.length == 1 ? width / 2 : width * i / (points.length - 1));
      if (i % labelStep == 0 || i == points.length - 1) {
        label('${points[i]['label']}', Offset(x - 8, top + height + 10));
      }
      final value = points[i]['percentage'];
      if (value is! num || !value.isFinite || value < 0 || value > 100) {
        previous = null;
        continue;
      }
      final point = Offset(x, top + height * (1 - value / 100));
      if (previous != null) canvas.drawLine(previous, point, ink);
      canvas.drawCircle(point, 4, ink);
      label('${value.round()}%', Offset(x - 12, point.dy - 18), color: const Color(0xFF871DAD));
      previous = point;
    }
  }

  @override
  bool shouldRepaint(covariant _PerformancePainter oldDelegate) => oldDelegate.points != points;
}
