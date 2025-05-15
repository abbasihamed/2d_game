import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:two_d_game/core/enums.dart';
import 'package:two_d_game/features/chess/presentation/widgets/chess_board.dart';

part 'chess_event.dart';
part 'chess_state.dart';

class ChessBloc extends Bloc<ChessEvent, ChessState> {
  ChessBloc() : super(ChessState(board: ChessBoard())) {
    on<ChessPieceSelected>(_onPieceSelected);
    on<ChessMoveMade>(_onMoveMade);
    on<ChessGameReset>(_onGameReset);
    on<ChessComputerMove>(_makeComputerMove);
  }

  void _onPieceSelected(ChessPieceSelected event, Emitter<ChessState> emit) {
    final piece = state.board.board[event.position.row][event.position.col];

    // If clicking on a piece of the current player's color
    if (piece != null && piece.color == state.board.currentTurn) {
      final validMoves = state.board.getValidMoves(event.position);
      emit(state.copyWith(
        selectedPiece: event.position,
        validMoves: validMoves,
      ));
    }
  }

  void _onMoveMade(ChessMoveMade event, Emitter<ChessState> emit) {
    if (state.validMoves.contains(event.to)) {
      // Create a clone of the board before making the move
      final newBoard = state.board.clone();
      newBoard.makeMove(event.from, event.to);

      emit(state.copyWith(
        board: newBoard,
        selectedPiece: null,
        validMoves: [],
        isGameOver: newBoard.isGameOver,
        winner: newBoard.winner,
      ));

      // If it's computer's turn and game is not over, trigger computer move
      if (!newBoard.isGameOver && newBoard.currentTurn == PieceColor.black) {
        add(ChessComputerMove());
      }
    }
  }

  void _onGameReset(ChessGameReset event, Emitter<ChessState> emit) {
    final newBoard = ChessBoard();
    emit(ChessState(
      board: newBoard,
      selectedPiece: null,
      validMoves: [],
      isGameOver: false,
      winner: null,
    ));
  }

  void _makeComputerMove(
      ChessComputerMove event, Emitter<ChessState> emit) async {
    // Simple AI: randomly select a valid move
    List<Position> allPossibleMoves = [];
    List<Position> allPossibleFrom = [];

    for (int i = 0; i < ChessBoard.boardSize; i++) {
      for (int j = 0; j < ChessBoard.boardSize; j++) {
        final piece = state.board.board[i][j];
        if (piece?.color == PieceColor.black) {
          final moves = state.board.getValidMoves(Position(i, j));
          if (moves.isNotEmpty) {
            allPossibleMoves.addAll(moves);
            allPossibleFrom.addAll(List.filled(moves.length, Position(i, j)));
          }
        }
      }
    }

    if (allPossibleMoves.isNotEmpty) {
      final randomIndex =
          DateTime.now().millisecondsSinceEpoch % allPossibleMoves.length;
      final from = allPossibleFrom[randomIndex];
      final to = allPossibleMoves[randomIndex];

      // Add a small delay to make the computer move feel more natural
      await Future.delayed(const Duration(milliseconds: 800));

      // Create a new board instance for the computer's move
      final newBoard = state.board.clone();
      newBoard.makeMove(from, to);

      emit(state.copyWith(
        board: newBoard,
        selectedPiece: null,
        validMoves: [],
        isGameOver: newBoard.isGameOver,
        winner: newBoard.winner,
      ));
    }
  }
}
