import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';

// Events
abstract class ChessEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChessPieceSelected extends ChessEvent {
  final Position position;

  ChessPieceSelected(this.position);

  @override
  List<Object?> get props => [position];
}

class ChessMoveMade extends ChessEvent {
  final Position from;
  final Position to;

  ChessMoveMade(this.from, this.to);

  @override
  List<Object?> get props => [from, to];
}

class ChessComputerMove extends ChessEvent {
  final Emitter<ChessState> emit;
  ChessComputerMove(this.emit);
}

class ChessGameReset extends ChessEvent {}

// State
class ChessState extends Equatable {
  final ChessBoard board;
  final Position? selectedPiece;
  final List<Position> validMoves;
  final bool isGameOver;
  final PieceColor? winner;

  const ChessState({
    required this.board,
    this.selectedPiece,
    this.validMoves = const [],
    this.isGameOver = false,
    this.winner,
  });

  ChessState copyWith({
    ChessBoard? board,
    Position? selectedPiece,
    List<Position>? validMoves,
    bool? isGameOver,
    PieceColor? winner,
  }) {
    return ChessState(
      board: board ?? this.board,
      selectedPiece: selectedPiece,
      validMoves: validMoves ?? this.validMoves,
      isGameOver: isGameOver ?? this.isGameOver,
      winner: winner,
    );
  }

  @override
  List<Object?> get props => [
        board,
        selectedPiece,
        validMoves,
        isGameOver,
        winner,
      ];
}

// BLoC
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
