part of 'chess_bloc.dart';

class ChessState extends Equatable {
  final ChessBoard board;
  final Position? selectedPiece;
  final List<Position> validMoves;
  final bool isGameOver;
  final PieceColor? winner;
  final List<ChessPiece> capturedWhitePieces;
  final List<ChessPiece> capturedBlackPieces;

  const ChessState({
    required this.board,
    this.selectedPiece,
    this.validMoves = const [],
    this.isGameOver = false,
    this.winner,
    this.capturedWhitePieces = const [],
    this.capturedBlackPieces = const [],
  });

  ChessState copyWith({
    ChessBoard? board,
    Position? selectedPiece,
    List<Position>? validMoves,
    bool? isGameOver,
    PieceColor? winner,
    List<ChessPiece>? capturedWhitePieces,
    List<ChessPiece>? capturedBlackPieces,
  }) {
    return ChessState(
      board: board ?? this.board,
      selectedPiece: selectedPiece,
      validMoves: validMoves ?? this.validMoves,
      isGameOver: isGameOver ?? this.isGameOver,
      winner: winner,
      capturedWhitePieces: capturedWhitePieces ?? this.capturedWhitePieces,
      capturedBlackPieces: capturedBlackPieces ?? this.capturedBlackPieces,
    );
  }

  @override
  List<Object?> get props => [
        board,
        selectedPiece,
        validMoves,
        isGameOver,
        winner,
        capturedWhitePieces,
        capturedBlackPieces,
      ];
}
