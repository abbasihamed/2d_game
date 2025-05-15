part of 'chess_bloc.dart';

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
