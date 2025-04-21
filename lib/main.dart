import 'package:flutter/material.dart';
import 'package:tictactoe/features/tic_tac_toe/presentation/screens/game_type_menu_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameTypeMenuPage(),
    );
  }
}
