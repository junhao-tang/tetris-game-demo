import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:tetris/game.dart';
import 'package:tetris/play/components/stored_pad.dart';

import 'components/tetris_pad.dart';
import 'constants.dart';
import 'components/block.dart';

Random _rand = Random();

class ActiveBlock {
  final List<BlockComponent> blocks;
  final BlockType blockType;
  BlockOrientation blockOrientation;

  ActiveBlock({
    required this.blockOrientation,
    required this.blocks,
    required this.blockType,
  });
}

class PlayView extends PositionComponent with HasGameRef<Tetris> {
  // relative to design
  // we can adapt to design by doing necessary adjustment
  // like scale, extend or whatever
  static const Offset tetrisPadPosition = Offset(0, 0);
  static const Offset storePosition = Offset(300, 40);
  static const Offset queuePosition = Offset(300, 150);
  static const Offset scoreTextPosition = Offset(300, 10);
  static const Offset gameOverTextPosition = Offset(250, 110);
  static const Color storeBackgroundColor = Color.fromARGB(255, 200, 200, 200);
  static const int queueSpacingBottom = 10;

  // game settings
  static const double secondsPerFall = 1.0;
  static const int gridRows = 17;
  static const int gridColumns = 10;
  static const int queueSize = 5;
  static const Offset spawnPosition = Offset(5, 0);
  static const BlockOrientation defaultOrientation = BlockOrientation.up;

  // components
  late final TetrisPadComponent _padComponent;
  late final StorePadComponent _storeComponent;
  late final List<StorePadComponent> _queueComponents = [];
  late final TextComponent _scoreComponent;
  late Timer _timer;

  // internals
  final Queue<BlockType> _queue = Queue<BlockType>();
  final List<List<BlockComponent?>> _blockAt = List.generate(
    gridRows,
    (_) => List.filled(gridColumns, null),
  );
  ActiveBlock? _activeBlock;
  bool _swapped = false;
  BlockType? _stashedBlockType;
  int _clearedRow = 0;

  @override
  Future<void> onLoad() async {
    size = Vector2(gridColumns.toDouble(), gridRows.toDouble());

    _padComponent = TetrisPadComponent(
      gridColumns: gridColumns,
      gridRows: gridRows,
    )..position = Vector2(
        tetrisPadPosition.dx,
        tetrisPadPosition.dy,
      );
    _storeComponent = StorePadComponent(backgroundColor: storeBackgroundColor)
      ..position = Vector2(
        storePosition.dx,
        storePosition.dy,
      );
    _scoreComponent = TextComponent(
      text: _clearedRow.toString(),
    )..position = Vector2(
        scoreTextPosition.dx,
        scoreTextPosition.dy,
      );
    _timer = Timer(
      1.0,
      onTick: () {
        if (_activeBlock == null) {
          spawnBlock(dequeueBlockType());
          if (isGameOver()) {
            _timer.stop();
            add(
              TextComponent(text: "GameOver")
                ..position = Vector2(
                  gameOverTextPosition.dx,
                  gameOverTextPosition.dy,
                ),
            );
          }
        } else {
          handleFall();
        }
      },
      repeat: true,
    );

    initializeQueue();
    await add(_padComponent);
    await add(_storeComponent);
    await add(_scoreComponent);
    await addAll(_queueComponents);
    spawnBlock(dequeueBlockType());
  }

  bool isGameOver() {
    if (_activeBlock == null) return false;
    return _activeBlock!.blocks.any(
      (b) => isBlocked(
        b.position.y.toInt(),
        b.position.x.toInt(),
      ),
    );
  }

  void initializeQueue() {
    for (int i = 0; i < queueSize; i++) {
      final blockType = randomBlockType;
      final q = StorePadComponent()
        ..position = Vector2(
          queuePosition.dx,
          (queuePosition.dy +
                  (StorePadComponent.designSize.height + queueSpacingBottom) *
                      (queueSize - 1 - i))
              .toDouble(),
        );
      _queue.add(blockType);
      _queueComponents.add(q);
    }
  }

  void handleKeyEvent(LogicalKeyboardKey key) {
    if (_activeBlock == null) return;
    ActiveBlock activeBlock = _activeBlock!;
    if (key == LogicalKeyboardKey.keyD || key == LogicalKeyboardKey.keyA) {
      var offset = -1;
      if (key == LogicalKeyboardKey.keyD) {
        offset = 1;
      }
      if (activeBlock.blocks.every((element) => !isBlocked(
            element.position.y.toInt(),
            element.position.x.toInt() + offset,
          ))) {
        for (final block in activeBlock.blocks) {
          block.position.x += offset;
        }
      }
    } else if (key == LogicalKeyboardKey.keyQ ||
        key == LogicalKeyboardKey.keyE) {
      final tryingOrientation =
          activeBlock.blockOrientation.rotate(key == LogicalKeyboardKey.keyQ);
      final formation =
          getBlockFormation(activeBlock.blockType, tryingOrientation);
      final tryingPositions = formation
          .map(
            (element) => Offset(
              activeBlock.blocks[0].position.x.toInt() + element.dx,
              activeBlock.blocks[0].position.y.toInt() + element.dy,
            ),
          )
          .toList();

      if (tryingPositions.every((element) => !isBlocked(
            element.dy.toInt(),
            element.dx.toInt(),
          ))) {
        for (int i = 0; i < tryingPositions.length; i++) {
          activeBlock.blocks[i].position.x = tryingPositions[i].dx;
          activeBlock.blocks[i].position.y = tryingPositions[i].dy;
        }
        activeBlock.blockOrientation = tryingOrientation;
      }
    } else if (key == LogicalKeyboardKey.keyS) {
      handleFall();
    } else if (key == LogicalKeyboardKey.space) {
      while (handleFall()) {}
    } else if (key == LogicalKeyboardKey.keyP) {
      swapBlock();
    }
  }

  @override
  void update(double dt) {
    _timer.update(dt);
  }

  bool handleFall() {
    if (_activeBlock != null) {
      ActiveBlock activeBlock = _activeBlock!;
      if (activeBlock.blocks.every(
        (element) => !isBlocked(
          element.position.y.toInt() + 1,
          element.position.x.toInt(),
        ),
      )) {
        for (final block in activeBlock.blocks) {
          block.position.y += 1;
        }
        return true;
      } else {
        for (final block in activeBlock.blocks) {
          final row = block.position.y.toInt();
          if (row <= 0) continue;
          _blockAt[row][block.position.x.toInt()] = block;
        }
        clearFilledRow();
        _swapped = false;
        _activeBlock = null;
      }
      return false;
    }
    return false;
  }

  void clearFilledRow() {
    // O(n)
    var firstEmpty = -1;
    for (int i = _blockAt.length - 1; i >= 0; i--) {
      if (_blockAt[i].every((element) => element != null)) {
        for (final b in _blockAt[i]) {
          _padComponent.remove(b!);
        }
        _blockAt[i] = List.filled(gridColumns, null);
        _clearedRow++;
        if (firstEmpty == -1) firstEmpty = i;
      } else if (firstEmpty != -1) {
        // swap with first empty. something like mergesort
        for (final b in _blockAt[i]) {
          if (b != null) b.position.y = firstEmpty.toDouble();
        }
        final tmp = _blockAt[i];
        _blockAt[i] = _blockAt[firstEmpty];
        _blockAt[firstEmpty] = tmp;
        firstEmpty--;
      }
    }
    _scoreComponent.text = _clearedRow.toString();
  }

  bool isBlocked(int r, int c) {
    if (r <= -1) return false;
    if (r >= gridRows) return true;
    if (c < 0 || c >= gridColumns) return true;
    if (_blockAt[r][c] != null) {
      return true;
    }
    return false;
  }

  BlockType get randomBlockType =>
      BlockType.values[_rand.nextInt(BlockType.values.length)];

  BlockType dequeueBlockType() {
    final current = _queue.removeFirst();
    _queue.add(randomBlockType);
    for (int i = 0; i < queueSize; i++) {
      _queueComponents[queueSize - 1 - i].setBlockType(_queue.elementAt(i));
    }
    return current;
  }

  ActiveBlock spawnBlock(BlockType spawningBlockType) {
    final blocks = getBlockFormation(
      spawningBlockType,
      defaultOrientation,
    )
        .map((e) => BlockComponent(
              blockType: spawningBlockType,
              position: Vector2(
                spawnPosition.dx + e.dx,
                spawnPosition.dy + e.dy,
              ),
            ))
        .toList();
    final activeBlock = ActiveBlock(
      blockType: spawningBlockType,
      blocks: blocks,
      blockOrientation: defaultOrientation,
    );
    _padComponent.addAll(blocks);
    _activeBlock = activeBlock;
    return activeBlock;
  }

  void swapBlock() {
    if (_swapped || _activeBlock == null) return;
    ActiveBlock activeBlock = _activeBlock!;
    _padComponent.removeAll(activeBlock.blocks);
    _swapped = true;
    final spawningBlockType = _stashedBlockType ?? dequeueBlockType();
    _stashedBlockType = activeBlock.blockType;
    _storeComponent.setBlockType(activeBlock.blockType);
    spawnBlock(spawningBlockType);
  }
}
