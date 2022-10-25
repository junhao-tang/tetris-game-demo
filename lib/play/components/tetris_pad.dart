import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// 1block = 1px
class TetrisPadComponent extends PositionComponent {
  static const Size designSize = Size(250, 450); // relative to design
  static const double strokeWidth = 0.01; // relative to 1.0
  static const Color lineColor = Colors.black;
  static const Color bgColor = Colors.grey;

  late final Paint _paint;
  late final Paint _gridPaint;
  final int gridColumns;
  final int gridRows;

  TetrisPadComponent({
    required this.gridColumns,
    required this.gridRows,
  }) {
    _paint = Paint()..color = bgColor;
    _gridPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    size = Vector2(
      gridColumns.toDouble(),
      gridRows.toDouble(),
    );
    scale = Vector2(
      designSize.width / gridColumns,
      designSize.height / gridRows,
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      _paint,
    );
    for (int r = 0; r < gridRows; r++) {
      canvas.drawLine(
        Offset(0, r.toDouble()),
        Offset(gridColumns.toDouble(), r.toDouble()),
        _gridPaint,
      );
    }
    for (int c = 0; c < gridColumns; c++) {
      canvas.drawLine(
        Offset(c.toDouble(), 0),
        Offset(c.toDouble(), gridRows.toDouble()),
        _gridPaint,
      );
    }
  }
}
