part of 'chess_bloc.dart';

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

class ChessComputerMove extends ChessEvent {}

class ChessGameReset extends ChessEvent {}
