import 'package:flutter/cupertino.dart';
import 'package:picsible/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Picsible',
      theme: const CupertinoThemeData(primaryColor: CupertinoColors.systemBlue, brightness: Brightness.light),
      home: const HomeScreen(title: 'Picsible Test'),
    );
  }
}
