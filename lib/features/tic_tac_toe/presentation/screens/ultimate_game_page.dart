import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tictactoe/core/enums.dart';
import 'package:tictactoe/core/utils/game_helpers.dart';
import 'package:tictactoe/features/tic_tac_toe/presentation/controllers/ultimate_tic_tac_toe_controller/ultimate_bloc.dart';
import 'package:tictactoe/features/tic_tac_toe/presentation/widgets/ultimate_board.dart';
import 'package:tictactoe/features/tic_tac_toe/presentation/widgets/winner_line.dart';

class UltimateGamePage extends StatelessWidget {
  final PlayerMode playerMode;
  const UltimateGamePage({super.key, required this.playerMode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UltimateBloc(playerMode: playerMode),
      child: Scaffold(
        appBar: AppBar(title: const Text('Ultimate Tic‑Tac‑Toe')),
        body: BlocBuilder<UltimateBloc, UltimateState>(
          builder: (context, state) {
            // Determine if there's a global winner pattern:
            final winPattern = getWinningPattern(state.localResults);

            return Column(
              children: [
                // The board with an optional victory line overlay
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: UltimateBoardWidget(state: state),
                        ),
                        if (winPattern != null)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: WinLinePainter(winPattern),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Current status or result text
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    state.gameResult == UltimateResult.ongoing
                        ? 'Turn: ${state.currentPlayer.name}'
                        : state.gameResult == UltimateResult.draw
                        ? 'Draw!'
                        : 'Winner: ${state.gameResult == UltimateResult.xWin ? 'X' : 'O'}',
                  ),
                ),

                // “Play Again” button when game is over
                if (state.gameResult != UltimateResult.ongoing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.replay),
                      label: const Text('Play Again'),
                      onPressed: () {
                        context.read<UltimateBloc>().add(UltimateReset());
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
