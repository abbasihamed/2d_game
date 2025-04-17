part of 'tic_tac_toe_bloc.dart';

class TicTacToeState {
  final List<Player?>
  board; // 9 cells: null if empty, Player.X or Player.O otherwise.
  final Player currentPlayer;
  final GameResult result;

  const TicTacToeState({
    required this.board,
    required this.currentPlayer,
    required this.result,
  });

  factory TicTacToeState.initial() {
    return TicTacToeState(
      board: List.filled(9, null),
      currentPlayer: Player.X,
      result: GameResult.ongoing,
    );
  }

  TicTacToeState copyWith({
    List<Player?>? board,
    Player? currentPlayer,
    GameResult? result,
  }) {
    return TicTacToeState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      result: result ?? this.result,
    );
  }
}
