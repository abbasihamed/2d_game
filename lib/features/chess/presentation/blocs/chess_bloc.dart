import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:two_d_game/features/chess/presentation/widgets/chess_board.dart';
import 'package:two_d_game/features/chess/presentation/widgets/chess_piece.dart';

part 'chess_event.dart';
part 'chess_state.dart';


class ChessBloc extends Bloc<ChessEvent, ChessState> {
  ChessBloc() : super(ChessState(board: ChessBoard())) {
    on<ChessPieceSelected>(_onPieceSelected);
    on<ChessMoveMade>(_onMoveMade);
    on<ChessGameReset>(_onGameReset);
    // on<ChessComputerMove>(_makeComputerMove);
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

  Future<void> _onMoveMade(
      ChessMoveMade event, Emitter<ChessState> emit) async {
    if (state.validMoves.contains(event.to)) {
      state.board.makeMove(event.from, event.to);
      emit(state.copyWith(
        board: state.board,
        selectedPiece: null,
        validMoves: [],
        isGameOver: state.board.isGameOver,
        winner: state.board.winner,
      ));

      // If it's computer's turn, make a move after a delay
      if (!state.isGameOver && state.board.currentTurn == PieceColor.black) {
        await _makeComputerMove(emit);
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

  Future<void> _makeComputerMove(Emitter<ChessState> emit) async {
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
    await Future.delayed(const Duration(milliseconds: 800));

    if (allPossibleMoves.isNotEmpty) {
      final randomIndex =
          DateTime.now().millisecondsSinceEpoch % allPossibleMoves.length;
      final from = allPossibleFrom[randomIndex];
      final to = allPossibleMoves[randomIndex];

      state.board.makeMove(from, to);

      emit(state.copyWith(
        board: state.board,
        isGameOver: state.board.isGameOver,
        winner: state.board.winner,
      ));
    }
  }
}
