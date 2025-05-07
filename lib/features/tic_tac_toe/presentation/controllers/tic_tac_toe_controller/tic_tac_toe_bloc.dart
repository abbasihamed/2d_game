import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:two_d_game/core/enums.dart';

part 'tic_tact_toe_event.dart';
part 'tic_toe_toe_state.dart';

class TicTacToeBloc extends Bloc<TicTacToeEvent, TicTacToeState> {
  final GameMode gameMode;

  TicTacToeBloc({required this.gameMode}) : super(TicTacToeState.initial()) {
    on<CellTapped>(_onCellTapped);
    on<ResetGame>(_onResetGame);
  }

  FutureOr<void> _onCellTapped(
    CellTapped event,
    Emitter<TicTacToeState> emit,
  ) async {
    final currentBoard = List<Player?>.from(state.board);

    // If cell already taken or game over, ignore tap
    if (currentBoard[event.index] != null ||
        state.result != GameResult.ongoing) {
      return null;
    }

    // Set move for current player
    currentBoard[event.index] = state.currentPlayer;
    final nextPlayer = state.currentPlayer == Player.X ? Player.O : Player.X;

    // Check for result using a use case or utility function (stubbed here)
    final result = _checkResult(currentBoard);

    emit(
      state.copyWith(
        board: currentBoard,
        currentPlayer: nextPlayer,
        result: result,
      ),
    );

    // If single-player and it is AI's turn, trigger AI move
    if (gameMode == GameMode.singlePlayer &&
        result == GameResult.ongoing &&
        nextPlayer == Player.O) {
      await _performAIMove(emit, currentBoard);
    }
  }

  void _onResetGame(ResetGame event, Emitter<TicTacToeState> emit) {
    emit(TicTacToeState.initial());
  }

  GameResult _checkResult(List<Player?> board) {
    // Stub function: check if either player won or the board is full (draw).
    // In a production app, delegate to a use case (e.g., CheckWinnerUseCase)
    // For brevity, we do minimal checking here:
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (final pattern in winPatterns) {
      final a = board[pattern[0]];
      if (a != null && a == board[pattern[1]] && a == board[pattern[2]]) {
        return a == Player.X ? GameResult.win : GameResult.lose;
      }
    }
    return board.contains(null) ? GameResult.ongoing : GameResult.draw;
  }

  int _minimax(List<Player?> board, bool isMaximizing) {
    final result = _checkResult(board);
    if (result != GameResult.ongoing) {
      if (result == GameResult.lose) return 1; // AI (O) wins
      if (result == GameResult.win) return -1; // Human (X) wins
      return 0; // Draw
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == null) {
          board[i] = Player.O;
          int score = _minimax(board, false);
          board[i] = null;
          bestScore = score > bestScore ? score : bestScore;
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == null) {
          board[i] = Player.X;
          int score = _minimax(board, true);
          board[i] = null;
          bestScore = score < bestScore ? score : bestScore;
        }
      }
      return bestScore;
    }
  }

  int _getBestAIMove(List<Player?> board) {
    int bestScore = -1000;
    int move = -1;
    for (int i = 0; i < board.length; i++) {
      if (board[i] == null) {
        board[i] = Player.O;
        int score = _minimax(board, false);
        board[i] = null;
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }
    return move;
  }

  Future<void> _performAIMove(
    Emitter<TicTacToeState> emit,
    List<Player?> board,
  ) async {
    // Add a slight delay for realism.
    await Future.delayed(const Duration(milliseconds: 500));

    final aiMoveIndex = _getBestAIMove(board);
    if (aiMoveIndex == -1) return;

    final newBoard = List<Player?>.from(board);
    newBoard[aiMoveIndex] = Player.O;
    final result = _checkResult(newBoard);
    emit(
      state.copyWith(board: newBoard, currentPlayer: Player.X, result: result),
    );
  }
}
