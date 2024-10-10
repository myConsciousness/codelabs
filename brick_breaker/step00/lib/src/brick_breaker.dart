import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:step00/src/components/components.dart';
import 'package:step00/src/config.dart';

/// このファイルはゲームのアクションを調整します。ゲーム インスタンスの構築時に、
/// このコードは固定解像度のレンダリングを使用するようにゲームを設定します。
///
/// ゲームのサイズが画面全体に表示されるようサイズ変更され、
/// 必要に応じてレターボックス表示が追加されます。
///
/// ゲームの幅と高さを公開して、
/// PlayAreaなどの子コンポーネントが自身を適切なサイズに設定できるようにします。
///
/// onLoad オーバーライドされたメソッドでは、コードが 2 つのアクションを実行します。
///
/// 左上をビューファインダーのアンカーに設定します。
///   デフォルトでは、ビューファインダーは領域の中央を (0,0) のアンカーとして使用します。
///   PlayArea を world に追加します。世界はゲームの世界を表すものです。
///   そのすべての子を CameraComponent のビュー変換を通じて投影します。
class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents {
  BrickBreaker()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  final rand = Random();

  double get width => size.x;
  double get height => size.y;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Anchor(0.0, 0.0)
    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PlayArea());

    world.add(Ball(
      radius: ballRadius,

      // 画面中央に表示。
      position: size / 2,

      // ボールの velocity を設定するには、より複雑な処理が必要となります。
      // 目的は、ボールを無作為な方向に適切な速度で画面下に移動することです。
      // normalized メソッドを呼び出すと、Vector2オブジェクトが作成され、
      // 元の Vector2 と同じ方向に設定されますが、距離 1 にスケールダウンされます。
      // これにより、ボールの方向にかかわらずボールの速度が一定になります。
      //その後、ボールの速度がゲームの高さの 4 分の 1 にスケールアップされます。
      velocity:
          Vector2((rand.nextDouble() - 0.5) * width, height * 0.2).normalized()
            ..scale(height / 4),
    ));

    world.add(Bat(
      size: Vector2(batWidth, batHeight),
      cornerRadius: const Radius.circular(ballRadius / 2),
      position: Vector2(width / 2, height * 0.95),
    ));

    debugMode = true;
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        world.children.query<Bat>().first.moveBy(-batStep);
      case LogicalKeyboardKey.arrowRight:
        world.children.query<Bat>().first.moveBy(batStep);
    }
    return KeyEventResult.handled;
  }
}
