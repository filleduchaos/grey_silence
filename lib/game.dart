import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';
import 'package:flame/gestures.dart';

import 'package:grey_silence/src/background.dart';
import 'package:grey_silence/src/objects.dart';
import 'package:grey_silence/src/player.dart';
import 'package:grey_silence/src/state.dart';
import 'package:grey_silence/src/ui.dart';

class GsGame extends GameWithState with TapDetector {
  GsState state;
  Player player;
  Background bg;
  Scoreboard scoreboard;
  ObjectsController gemController;

  GsGame() {
    state = GsState();
    add(bg = Background());
    add(gemController = ObjectsController());
    add(player = Player());
    add(scoreboard = Scoreboard());
  }

  @override
  void resize(Size size) {
    state.setTileSize(size.height);
    super.resize(size);
  }

  @override
  void onTapUp(details) {
    switch (state.mode) {
      case GsMode.start:
        player.run();
        break;
      case GsMode.playing:
        player.flip();
        break;
      case GsMode.gameOver:
        state.reset();
        player.getUp();
        break;
    }
  }

  @override
  void endGame() {
    player.die();
  }

  @override
  void update(double t) {
    if (state.mode.nowPlaying) {
      camera.x += t * state.speed;
      state.setDistanceRunFromCamera(camera.x);
      state.checkCondition();
    }
    super.update(t);
  }

  @override
  bool playerCollisionWith(PositionComponent c) {
    return player.distance(c) < player.width / 2;
  }
}
