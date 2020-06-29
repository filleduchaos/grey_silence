import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/flame.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' hide Animation;

import 'package:grey_silence/src/state.dart';

const transparent = Color(0x009E9E9E);
const grey = Color(0xFF9E9E9E);

class Background extends SpriteComponent with HasGameRef<GameWithState> {
  Background();

  static const speed = -60.0;
  static const aspectRatio = 24 / 11; // 768×352

  ColorFilter _getColorFilter() {
    var delta = (gameRef.state.score / kWinningScore).clamp(0, kWinningScore);

    return ColorFilter.mode(
      Color.lerp(grey, transparent, delta),
      BlendMode.saturation,
    );
  }

  @override
  void resize(Size size) {
    // Todo: handle large screens?
    height = 11 * gameRef.state.tileSize;
    width = 24 * gameRef.state.tileSize;
    x = 0;
    y = 3 * gameRef.state.tileSize;
    setSprite();
  }

  void setSprite() async {
    sprite = await Sprite.loadSprite('background.png');
  }

  @override
  void update(double dt) {
    super.update(dt);

    sprite?.paint?.colorFilter = _getColorFilter();

    if (gameRef.camera.x - x > width) {
      x += width;
    }
  }

  void renderSprite(Canvas canvas) {
    sprite.render(canvas, width: width, height: height);
  }

  @override
  void render(Canvas canvas) {
    if (sprite == null) return;

    for (var i = 0; i < 3; i++) {
      var shift = width * i;
      Flame.util.drawWhere(canvas, Position(x + shift, y), renderSprite);
    }
  }
}
