import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:two_d_game/core/enums.dart';
import 'package:two_d_game/features/chess/presentation/widgets/chess_board.dart';
import 'package:two_d_game/features/chess/presentation/widgets/chess_piece.dart';

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

  // Shared method to handle move and capture logic
  ChessState _handleMove(Position from, Position to, ChessState currentState) {
    // Create a clone of the board before making the move
    final newBoard = currentState.board.clone();

    // Check if there's a piece at the destination (capture)
    final capturedPiece = newBoard.board[to.row][to.col];

    // Update captured pieces lists
    List<ChessPiece> newCapturedWhitePieces =
        List.from(currentState.capturedWhitePieces);
    List<ChessPiece> newCapturedBlackPieces =
        List.from(currentState.capturedBlackPieces);

    if (capturedPiece != null) {
      // Add the captured piece to the appropriate list based on its color
      if (capturedPiece.color == PieceColor.white) {
        newCapturedWhitePieces.add(capturedPiece);
      } else {
        newCapturedBlackPieces.add(capturedPiece);
      }
    }

    // Make the move on the board
    newBoard.makeMove(from, to);

    return currentState.copyWith(
      board: newBoard,
      selectedPiece: null,
      validMoves: [],
      isGameOver: newBoard.isGameOver,
      winner: newBoard.winner,
      capturedWhitePieces: newCapturedWhitePieces,
      capturedBlackPieces: newCapturedBlackPieces,
    );
  }

  void _onMoveMade(ChessMoveMade event, Emitter<ChessState> emit) {
    if (state.validMoves.contains(event.to)) {
      // Use the shared method to handle the move
      final newState = _handleMove(event.from, event.to, state);
      emit(newState);

      // If it's computer's turn and game is not over, trigger computer move
      if (!newState.board.isGameOver && newState.board.currentTurn == PieceColor.black) {
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
      capturedWhitePieces: [],
      capturedBlackPieces: [],
    ));
  }

  void _makeComputerMove(
      ChessComputerMove event, Emitter<ChessState> emit) async {
    // Simple AI: randomly select a valid move
    List<Position> allPossibleMoves = [];
    List<Position> allPossibleFrom = [];
    
    // Check if the computer (black) is in check
    final isInCheck = state.board.isKingInCheck(PieceColor.black);
    
    for (int i = 0; i < ChessBoard.boardSize; i++) {
      for (int j = 0; j < ChessBoard.boardSize; j++) {
        final piece = state.board.board[i][j];
        if (piece?.color == PieceColor.black) {
          final moves = state.board.getValidMoves(Position(i, j));
          if (moves.isNotEmpty) {
            // If in check, we need to prioritize moves that get out of check
            if (isInCheck) {
              for (final move in moves) {
                // Create a temporary board to test if this move escapes check
                final tempBoard = state.board.clone();
                tempBoard.makeMove(Position(i, j), move);
                
                // If this move escapes check, add it to our priority list
                if (!tempBoard.isKingInCheck(PieceColor.black)) {
                  allPossibleMoves.add(move);
                  allPossibleFrom.add(Position(i, j));
                }
              }
            } else {
              // Not in check, add all valid moves
              allPossibleMoves.addAll(moves);
              allPossibleFrom.addAll(List.filled(moves.length, Position(i, j)));
            }
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

      // Use the shared method to handle the move
      final newState = _handleMove(from, to, state);
      emit(newState);
    }
  }
}
