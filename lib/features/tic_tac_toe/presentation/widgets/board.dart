import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:two_d_game/core/enums.dart';
import 'package:two_d_game/features/tic_tac_toe/presentation/controllers/tic_tac_toe_controller/tic_tac_toe_bloc.dart';

class BoardWidget extends StatelessWidget {
  final List<Player?> board;
  const BoardWidget({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 9,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (_, index) {
        final cell = board[index];
        return GestureDetector(
          onTap: () {
            context.read<TicTacToeBloc>().add(CellTapped(index: index));
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                cell == null ? '' : (cell == Player.X ? 'X' : 'O'),
                style: TextStyle(
                  fontSize: 32,
                  color:
                      cell == null
                          ? null
                          : cell == Player.X
                          ? Colors.red
                          : Colors.green,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
