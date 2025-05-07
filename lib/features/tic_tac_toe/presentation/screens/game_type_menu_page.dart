import 'package:flutter/material.dart';
import 'package:two_d_game/core/enums.dart';
import 'package:two_d_game/features/tic_tac_toe/presentation/screens/player_mode_menu_page.dart';

class GameTypeMenuPage extends StatelessWidget {
  const GameTypeMenuPage({super.key});

  void _onSelect(BuildContext context, GameType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerModeMenuPage(gameType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Game Type')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _onSelect(context, GameType.classic),
              child: const Text('Classic Tic‑Tac‑Toe'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _onSelect(context, GameType.ultimate),
              child: const Text('Ultimate Tic‑Tac‑Toe'),
            ),
          ],
        ),
      ),
    );
  }
}
