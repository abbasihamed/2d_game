import 'package:flutter/material.dart';
import 'package:tictactoe/core/enums.dart';
import 'package:tictactoe/features/tic_tac_toe/presentation/screens/game_page.dart';
import 'package:tictactoe/features/tic_tac_toe/presentation/screens/ultimate_game_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  void _startGame(BuildContext context, GameMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GamePage(gameMode: mode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe')),
      body: Center(
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _startGame(context, GameMode.singlePlayer),
              child: const Text('Single Player'),
            ),
            ElevatedButton(
              onPressed: () => _startGame(context, GameMode.twoPlayer),
              child: const Text('Two Players'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UltimateGamePage()),
                );
              },
              child: const Text('Ultimate Tic‑Tac‑Toe'),
            ),
          ],
        ),
      ),
    );
  }
}
