import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';
import 'package:grey_silence/src/state.dart';

const _baseTextConfig = TextConfig(fontFamily: 'Retro', color: Color(0xffffffca));

class Scoreboard extends PositionComponent with HasGameRef<GameWithState> {
  TextConfig _config;

  Scoreboard() {
    anchor = Anchor.topCenter;
  }

  @override
  void resize(Size size) {
    height = gameRef.state.tileSize;
    width = size.width;
    x = width / 2;
    y = height;
    _config = _baseTextConfig.withFontSize(height);
  }

  String get text {
    switch (gameRef.state.mode) {
      case GsMode.start:
        return "Tap to Start";
      case GsMode.playing:
        return "(Score : ${gameRef.state.score})";
      case GsMode.gameOver:
        return "Game Over (Score : ${gameRef.state.score})";
    }
    return "";
  }

  @override
  void render(Canvas canvas) {
    _config.render(canvas, text, toPosition(), anchor: anchor);
  }

  @override
  bool isHud() => true;
}
