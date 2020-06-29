import 'dart:ui';
import 'package:flame/anchor.dart';
import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:grey_silence/src/state.dart';

enum PlayerMode {
  idle,
  running,
  flipping,
  dead,
}

extension on PlayerMode {
  bool get isTransient => this == PlayerMode.flipping || this == PlayerMode.dead;
}

extension<K, V> on Map<K, V> {
  V get(K key) {
    return this[key];
  }
}

extension on Animation {
  // Adjusted to run from 0 to 1 and back to 0
  double get asJumpProgress => 1 - ((2 * elapsed / totalDuration()) - 1).abs();
}

const _kSize = 64.0;
const _kTileSize = 3;
const _kJumpTiles = 4;

Animation _buildAnimation(String type, int count, { bool loop = true }) {
  return Animation.sequenced(
    'player-$type.png',
    count,
    textureHeight: _kSize,
    textureWidth: _kSize,
    loop: loop,
  );
}

Map<PlayerMode, Animation> _buildAnimations() => {
  PlayerMode.idle: _buildAnimation('idle', 4),
  PlayerMode.running: _buildAnimation('run', 8),
  PlayerMode.dead: _buildAnimation('die', 4)
                          ..loop = false,
  PlayerMode.flipping: _buildAnimation('backflip', 10)
                          ..loop = false
                          ..stepTime = 0.075
};

class Player extends AnimationComponent with HasGameRef<GameWithState> {
  static const kBaseline = 12.0;

  Player() : _animations = _buildAnimations(), super.empty() {
    _animations[PlayerMode.flipping].onCompleteAnimation = onFlipComplete;
    _animations[PlayerMode.dead].onCompleteAnimation = onDyingComplete;
    animation = _animations[mode];
    anchor = Anchor.bottomLeft;
  }

  final Map<PlayerMode, Animation> _animations;

  double _relativeY = kBaseline;

  PlayerMode _mode = PlayerMode.idle;

  PlayerMode get mode => _mode;

  void _switchToMode(PlayerMode m) {
    _mode = m;
    var nextAnimation = _animations[mode];
    if (animation != nextAnimation) {
      animation.reset();
      animation = nextAnimation;
    }
  }

  void run() {
    if (gameRef.state.mode == GsMode.start) {
      _switchToMode(PlayerMode.running);
      gameRef.state.mode = GsMode.playing;
    }
  }

  void flip() {
    if (gameRef.state.nowPlaying) _switchToMode(PlayerMode.flipping);
  }

  void onFlipComplete() {
    if (gameRef.state.nowPlaying) _switchToMode(PlayerMode.running);
  }

  void die() {
    if (gameRef.state.nowPlaying) _switchToMode(PlayerMode.dead);
  }

  void onDyingComplete() {
    if (gameRef.state.nowPlaying) {
      gameRef.state.mode = GsMode.gameOver;
    }
  }

  void getUp() {
    if (gameRef.state.mode == GsMode.gameOver) {
      _switchToMode(PlayerMode.idle);
      gameRef.state.mode = GsMode.start;
    }
  }

  void _updateRelativeY({ double jumpProgress = 0 }) {
    // Twelve tiles plus 1/16 tiles to "stand" on the actual path
    var t = 1.0 - jumpProgress;
    var jumpHeight = (1.0 - t * t) * _kJumpTiles;
    _relativeY = (kBaseline - jumpHeight).clamp(0, kBaseline);
  }

  @override
  void resize(Size size) {
    width = height = ts(_kTileSize);
    _updatePosition();
  }

  void _updatePosition({ double jumpProgress = 0 }) {
    var jumpProgress = mode.isTransient ? animation.asJumpProgress : 0.0;
    _updateRelativeY(jumpProgress: jumpProgress);
    x = ts(3 + gameRef.state.lifetimeDistanceRun);
    y = ts(_relativeY + 0.0625);
  }

  @override
  void update(double t) {
    _updatePosition();
    super.update(t);
  }
}
