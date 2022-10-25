import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tetris/play/components/block.dart';

import '../constants.dart';

class StorePadComponent extends PositionComponent {
  static const Size designSize = Size(50, 50); // relative to design
  static const int gridColumns = 5;
  static const int gridRows = 5;
  static const Map<BlockType, Offset> originMap = {};

  final Paint _paint;
  BlockType? _blockType;
  List<BlockComponent>? _blocks;

  StorePadComponent({Color backgroundColor = Colors.grey})
      : _paint = Paint()..color = backgroundColor {
    size = Vector2(
      gridColumns.toDouble(),
      gridRows.toDouble(),
    );
    scale = Vector2(
      designSize.width / gridColumns,
      designSize.height / gridRows,
    );
  }

  void setBlockType(BlockType blockType) {
    if (_blockType == blockType) return;
    _blockType = blockType;
    if (_blocks != null) {
      removeAll(_blocks!);
    }
    var origin = originMap[blockType] ??
        Offset(
          (gridColumns ~/ 2).toDouble(),
          (gridRows ~/ 2).toDouble(),
        );
    _blocks = getBlockFormation(blockType, BlockOrientation.up)
        .map(
          (e) => BlockComponent(
            blockType: _blockType!,
            position: Vector2(origin.dx + e.dx, origin.dy + e.dy),
          ),
        )
        .toList();
    addAll(_blocks!);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      _paint,
    );
  }
}
