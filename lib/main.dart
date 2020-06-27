import 'package:flutter/material.dart';
import 'package:flame/flame.dart';

import 'package:grey_silence/game.dart';

void main() async {
  await Flame.util.fullScreen();
  await Flame.util.setLandscape();
  final screenSize = await Flame.util.initialDimensions();

  final game = GSGame(screenSize);
  runApp(game.widget);
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
