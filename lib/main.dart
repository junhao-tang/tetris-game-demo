import 'package:flutter/material.dart';
import 'package:tetris/game.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  const designSize = Size(400, 500);
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: designSize,
    maximumSize: designSize,
    minimumSize: designSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetris Demo',
      home: Scaffold(
        backgroundColor: Colors.white,
        body: createGameWidget(Tetris()),
      ),
    );
  }
}
