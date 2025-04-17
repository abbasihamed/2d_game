part of 'tic_tac_toe_bloc.dart';

sealed class TicTacToeEvent {
  const TicTacToeEvent();
}

class CellTapped extends TicTacToeEvent {
  final int index;
  const CellTapped({required this.index});
}

class ResetGame extends TicTacToeEvent {
  const ResetGame();
}
