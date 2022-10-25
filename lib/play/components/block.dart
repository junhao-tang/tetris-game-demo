import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tetris/play/constants.dart';

// 1block = 1pixel
class BlockComponent extends PositionComponent {
  static const Map<BlockType, Color> colorsMap = {
    BlockType.square: Colors.red,
    BlockType.straight: Colors.green,
    BlockType.t: Colors.purple,
  };
  final Paint _paint;

  BlockComponent({required BlockType blockType, required super.position})
      : _paint = Paint()..color = colorsMap[blockType]! {
    size = Vector2(1, 1);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}
