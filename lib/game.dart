import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/gestures.dart';

import 'package:grey_silence/src/player.dart';

class GSGame extends BaseGame with TapDetector {
  static final _white = Paint()..color = Color(0xFFFFFFFF);
  static final _darkGrey = Paint()..color = Color(0xFF333333);

  Player player;

  GSGame(Size screenSize) {
    size = screenSize;

    init();
  }

  @override
  void onTapDown(TapDownDetails details) {
    if (details.globalPosition.dx >= size.width / 2) {
      player.moveRight();
    } else {
      player.moveLeft();
    }
  }

  @override
  void onTapUp(TapUpDetails details) {
    player.stopMoving();
  }

  void init() {
    add(
      StaticComponent()
      ..x = 50
      ..y = size.height - 120
      ..width = size.width * 2
      ..height = 100
      ..paint = _white
    );
    
    for (int i = 1; i < 6; i++) {
      add(
        StaticComponent()
        ..x = 250.0 * i
        ..y = size.height - 220
        ..width = 100
        ..height = 100
        ..paint = _darkGrey
      );
    }
    
    add(
      player = Player(this)
      ..x = 100
      ..y = size.height - 220
      ..width = 50
      ..height = 100
    );
  }
}

class StaticComponent extends PositionComponent {
  Paint paint;

  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {
    canvas.drawRect(toRect(), paint);
  }
}

