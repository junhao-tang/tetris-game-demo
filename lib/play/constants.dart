import 'dart:ui';

enum BlockType {
  t,
  square,
  straight,
}

enum BlockOrientation { up, down, left, right }

const Map<BlockOrientation, int> blockOrientationValue = {
  BlockOrientation.up: 0,
  BlockOrientation.right: 1,
  BlockOrientation.down: 2,
  BlockOrientation.left: 3,
};
final reverseBlockOrientation = Map.unmodifiable(blockOrientationValue
    .map((key, value) => MapEntry<int, BlockOrientation>(value, key)));

extension Value on BlockOrientation {
  BlockOrientation rotate(bool isClockWise) {
    final int blockOrientationValueSize = blockOrientationValue.keys.length;
    var value = blockOrientationValue[this]!;
    value = (blockOrientationValueSize + value + (isClockWise ? 1 : -1)) %
        blockOrientationValueSize;
    return reverseBlockOrientation[value];
  }
}

const Map<BlockType, Map<BlockOrientation, List<Offset>>> blocksFormation = {
  BlockType.t: {
    BlockOrientation.up: [
      Offset(0, 0),
      Offset(-1, 1),
      Offset(0, 1),
      Offset(1, 1),
    ],
    BlockOrientation.right: [
      Offset(0, 0),
      Offset(1, 1),
      Offset(1, 0),
      Offset(1, -1),
    ],
    BlockOrientation.down: [
      Offset(0, 0),
      Offset(1, -1),
      Offset(0, -1),
      Offset(-1, -1),
    ],
    BlockOrientation.left: [
      Offset(0, 0),
      Offset(-1, -1),
      Offset(-1, 0),
      Offset(-1, 1),
    ],
  },
  BlockType.square: {
    BlockOrientation.up: [
      Offset(0, 0),
      Offset(-1, -1),
      Offset(-1, 0),
      Offset(0, -1),
    ],
    BlockOrientation.right: [
      Offset(0, 0),
      Offset(-1, -1),
      Offset(-1, 0),
      Offset(0, -1),
    ],
    BlockOrientation.down: [
      Offset(0, 0),
      Offset(-1, -1),
      Offset(-1, 0),
      Offset(0, -1),
    ],
    BlockOrientation.left: [
      Offset(0, 0),
      Offset(-1, -1),
      Offset(-1, 0),
      Offset(0, -1),
    ],
  },
  BlockType.straight: {
    BlockOrientation.up: [
      Offset(0, 0),
      Offset(0, -2),
      Offset(0, -1),
      Offset(0, 1),
    ],
    BlockOrientation.right: [
      Offset(0, 0),
      Offset(-2, 0),
      Offset(-1, 0),
      Offset(1, 0),
    ],
    BlockOrientation.down: [
      Offset(0, 0),
      Offset(0, -2),
      Offset(0, -1),
      Offset(0, 1),
    ],
    BlockOrientation.left: [
      Offset(0, 0),
      Offset(-2, 0),
      Offset(-1, 0),
      Offset(1, 0),
    ],
  }
};

List<Offset> getBlockFormation(
    BlockType blockType, BlockOrientation orientation) {
  return blocksFormation[blockType]![orientation]!;
}
