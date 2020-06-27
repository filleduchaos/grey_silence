import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game/base_game.dart';

enum PlayerState {
  left,
  neutral,
  right
}

extension on PlayerState {
  int get asInt {
    return this.index - 1;
  }
}

class Player extends PositionComponent {
  static final _blue = Paint()..color = Color(0xFF0000FF);
  static const double SPEED = 300;

  Player(this.game);

  final BaseGame game;

  PlayerState _direction = PlayerState.neutral;

  void moveRight() {
    _direction = PlayerState.right;
  }

  void moveLeft() {
    _direction = PlayerState.left;
  }

  void stopMoving() {
    _direction = PlayerState.neutral;
  }

  @override
  void update(double dt) {
    final step = _direction.asInt * SPEED * dt;
    x += step;
    game.camera.x += step;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(toRect(), _blue);
  }
}
