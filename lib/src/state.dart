import 'dart:math';
import 'package:flame/components/component.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

enum GsMode {
  start,
  playing,
  gameOver,
}

extension GsModeMethods on GsMode {
  bool get nowPlaying => this == GsMode.playing;
}

const kTileCount = 16;
const _maxSpeedLevel = 6;
const _baseTps = 12.0;
const _deltaTps = 2.0;

const _kGemPoints = 5;
const _kRunPoints = 0.5;

const kWinningScore = 1500;

abstract class GameWithState extends BaseGame {
  GsState get state;

  bool playerCollisionWith(PositionComponent c);

  void endGame();
}

extension TileSizeHelper on HasGameRef<GameWithState> {
  double ts(num relative) => relative * gameRef.state.tileSize;
}

class GsState {
  bool get nowPlaying => mode == GsMode.playing;

  GsState() {
    reset();
  }

  final _random = Random();

  reset() {
    _distanceRun = 0;
    _speedLevel = 0;
    _gemsCollected = 0;
  }

  void setTileSize(double screenHeight) {
    tileSize = screenHeight / kTileCount;
  }

  double tileSize = 0;
  GsMode mode = GsMode.start;

  double _distanceRun;
  double _speedLevel;
  int _gemsCollected;
  int get gemsCollected => _gemsCollected;

  double _lifetimeDistanceRun = 0;
  double get relativeDistanceRun => _distanceRun / tileSize;
  double get lifetimeDistanceRun => _lifetimeDistanceRun / tileSize;
  void setDistanceRunFromCamera(double distance) {
    var delta = distance - _lifetimeDistanceRun;
    _lifetimeDistanceRun = distance;
    _distanceRun += delta;
  }

  double get speed => (_baseTps + (_deltaTps * _speedLevel)) * tileSize;
  int get score => (relativeDistanceRun * _kRunPoints).floor() + (_gemsCollected * _kGemPoints);

  void checkCondition() {
    if (_speedLevel < _maxSpeedLevel && score >= (1 + _speedLevel) * 200) {
      _speedLevel += 1;
    }
  }

  void collectGem() {
    if (mode == GsMode.playing) {
      _gemsCollected += 1;
    }
  }

  int randomInt(int min, int max) {
    return _random.nextInt(max) + min;
  }

  bool randomBool() => _random.nextBool();
}
