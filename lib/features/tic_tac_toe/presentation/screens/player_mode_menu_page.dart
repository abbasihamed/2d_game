import 'package:flutter/material.dart';
import 'package:two_d_game/core/enums.dart';
import 'package:two_d_game/features/tic_tac_toe/presentation/screens/game_page.dart';
import 'package:two_d_game/features/tic_tac_toe/presentation/screens/ultimate_game_page.dart';

class PlayerModeMenuPage extends StatelessWidget {
  final GameType gameType;
  const PlayerModeMenuPage({super.key, required this.gameType});

  void _onSelect(BuildContext context, PlayerMode mode) {
    switch (gameType) {
      case GameType.classic:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => GamePage(
                  gameMode:
                      mode == PlayerMode.single
                          ? GameMode.singlePlayer
                          : GameMode.twoPlayer,
                ),
          ),
        );
        break;
      case GameType.ultimate:
        // Currently only two-player ultimate is supported
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UltimateGamePage(playerMode: mode)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Player Mode')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _onSelect(context, PlayerMode.single),
              child: const Text('Single Player'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _onSelect(context, PlayerMode.two),
              child: const Text('Two Players'),
            ),
          ],
        ),
      ),
    );
  }
}
