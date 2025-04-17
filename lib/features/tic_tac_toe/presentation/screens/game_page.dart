import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tictactoe/core/enums.dart';
import 'package:tictactoe/features/tic_tac_toe/presentation/controllers/tic_tac_toe_controller/tic_tac_toe_bloc.dart';
import 'package:tictactoe/features/tic_tac_toe/presentation/widgets/board.dart';

class GamePage extends StatelessWidget {
  final GameMode gameMode;
  const GamePage({super.key, required this.gameMode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TicTacToeBloc(gameMode: gameMode),
      child: const GameView(),
    );
  }
}

class GameView extends StatelessWidget {
  const GameView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Play Tic Tac Toe')),
      body: BlocConsumer<TicTacToeBloc, TicTacToeState>(
        listener: (context, state) {
          if (state.result != GameResult.ongoing) {
            final message =
                state.result == GameResult.draw
                    ? 'It\'s a Draw!'
                    : 'Player ${state.result == GameResult.win ? 'X' : 'O'} Wins!';
            // Show dialog when game ends.
            showDialog(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: const Text('Game Over'),
                    content: Text(message),
                    actions: [
                      TextButton(
                        onPressed: () {
                          context.read<TicTacToeBloc>().add(ResetGame());
                          Navigator.pop(context);
                        },
                        child: const Text('Play Again'),
                      ),
                    ],
                  ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(child: BoardWidget(board: state.board)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Current Turn: ${state.currentPlayer == Player.X ? 'X' : 'O'}',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
