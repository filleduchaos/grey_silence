import 'package:flame/anchor.dart';
import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flutter/material.dart' hide Animation;

import 'package:grey_silence/src/state.dart';

const _kMinSpacingTiles = 12;
const _kMaxTilesWithoutObject = 60;
const _kMaxGroupedGems = 4;
const _kGemRunningHeight = 8;
const _kGemJumpingHeight = 11;
const _kTurretHeight = 12.0625;

class ObjectsController extends Component with HasGameRef<GameWithState> {
  final List<GsObjectComponent> components = [];

  @override
  void render(Canvas canvas) {
    canvas.save();
    components.forEach((comp) => _renderComponent(canvas, comp));
    canvas.restore();
  }

  void _renderComponent(Canvas canvas, Component c) {
    if (!c.loaded()) {
      return;
    }
    c.render(canvas);
    canvas.restore();
    canvas.save();
  }

  @override
  void resize(Size size) {
    if (components.length <= 20) spawn();
    for (var c in components) c.resize(size);
  }

  @override
  void update(double t) {
    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy());
    if (components.length <= 20) spawn();
  }

  void add(Component c) {
    gameRef.preAdd(c);
    components.add(c);
  }

  void spawn({ int count = 60 }) {
    for (var i = 0; i < count; i++) {
      var isGem = gameRef.state.randomBool();
      var tilesToNext = gameRef.state.randomInt(_kMinSpacingTiles, _kMaxTilesWithoutObject);
      tilesToNext += components.isEmpty ? 30 : components.last.relativeX;

      if (isGem) {
        var groupCount = gameRef.state.randomInt(1, _kMaxGroupedGems);
        var floating = gameRef.state.randomBool();

        for (var i = 0; i < groupCount; i++) {
          add(Gem(
            tilesToNext + i,
            floating ? _kGemJumpingHeight : _kGemRunningHeight,
          ));
        }
      }
      else {
        if (components.isNotEmpty && components.last.relativeY == _kGemJumpingHeight) {
          tilesToNext -= gameRef.state.randomInt(0, _kMinSpacingTiles - 5);
        }

        add(Turret(tilesToNext));
      }
    }
  }
}

abstract class GsObjectComponent extends AnimationComponent with HasGameRef<GameWithState> {
  final num relativeX;
  final num relativeY;

  GsObjectComponent(this.relativeX, this.relativeY) : super.empty();

  void onCollision();

  double get relativeSize;

  bool _destroy = false;

  @override
  void resize(Size size) {
    width = height = ts(relativeSize);
    y = ts(relativeY);
    x = ts(relativeX);
  }

  @override
  void update(double t) {
    if (gameRef.playerCollisionWith(this)) {
      onCollision();
    }
    else if (x + 20 < gameRef.camera.x) {
      _destroy = true;
    }

    super.update(t);
  }

  @override
  bool destroy() => _destroy;
}


class Gem extends GsObjectComponent {
  Gem(int x, int y) : super(x, y) {
    animation = Animation.sequenced('gem.png', 30, textureWidth: 32, textureHeight: 32, stepTime: 0.05);
    anchor = Anchor.center;
  }

  @override
  double get relativeSize => .75;

  @override
  void onCollision() {
    gameRef.state.collectGem();
    _destroy = true;
  }
}

class Turret extends GsObjectComponent {
  Turret(int x) : super(x, _kTurretHeight) {
    animation = Animation.sequenced('turret.png', 6, textureWidth: 25, textureHeight: 23, stepTime: 0.15);
    anchor = Anchor.bottomCenter;
  }

  @override
  double get relativeSize => 1.4;

  @override
  void onCollision() {
    gameRef.endGame();
  }
}
