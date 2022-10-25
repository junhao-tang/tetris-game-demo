import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tetris/play/view.dart';

GameWidget createGameWidget(Tetris game) {
  return GameWidget<Tetris>(
    game: game,
  );
}

class Tetris extends FlameGame with KeyboardEvents {
  late PlayView view;

  @override
  Future<void> onLoad() async {
    view = PlayView();
    add(view);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    if (!isLoaded) {
      return KeyEventResult.ignored;
    }

    for (final key in keysPressed) {
      view.handleKeyEvent(key);
    }
    return KeyEventResult.handled;
  }
}
