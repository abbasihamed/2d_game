import 'package:two_d_game/core/enums.dart';

import 'chess_piece.dart';

class Position {
  final int row;
  final int col;

  Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class ChessBoard {
  static const int boardSize = 8;
  List<List<ChessPiece?>> board;
  PieceColor currentTurn;
  Position? selectedPiece;
  List<Position> validMoves;
  bool isGameOver;
  PieceColor? winner;
  Position? enPassantTarget; // Add this field for en passant

  ChessBoard()
      : board = List.generate(
          boardSize,
          (i) => List.generate(boardSize, (j) => null),
        ),
        currentTurn = PieceColor.white,
        validMoves = [],
        isGameOver = false,
        winner = null,
        enPassantTarget = null {
    _initializeBoard();
  }

  // Private constructor for cloning
  ChessBoard._clone(
    this.board,
    this.currentTurn,
    this.selectedPiece,
    this.validMoves,
    this.isGameOver,
    this.winner,
    this.enPassantTarget,
  );

  // Create a deep clone of the board
  ChessBoard clone() {
    // Deep copy the board
    final boardCopy = List.generate(
      boardSize,
      (i) => List.generate(
        boardSize,
        (j) => board[i][j]?.copyWith(hasMoved: board[i][j]?.hasMoved ?? false),
      ),
    );

    // Clone everything else
    return ChessBoard._clone(
      boardCopy,
      currentTurn,
      selectedPiece,
      List.from(validMoves),
      isGameOver,
      winner,
      enPassantTarget,
    );
  }

  void _initializeBoard() {
    // Initialize pawns
    for (int i = 0; i < boardSize; i++) {
      board[1][i] = ChessPiece(type: PieceType.pawn, color: PieceColor.black);
      board[6][i] = ChessPiece(type: PieceType.pawn, color: PieceColor.white);
    }

    // Initialize other pieces
    final backRankPieces = [
      PieceType.rook,
      PieceType.knight,
      PieceType.bishop,
      PieceType.queen,
      PieceType.king,
      PieceType.bishop,
      PieceType.knight,
      PieceType.rook,
    ];

    for (int i = 0; i < boardSize; i++) {
      board[0][i] = ChessPiece(
        type: backRankPieces[i],
        color: PieceColor.black,
      );
      board[7][i] = ChessPiece(
        type: backRankPieces[i],
        color: PieceColor.white,
      );
    }
  }

  List<Position> getValidMoves(Position position) {
    final piece = board[position.row][position.col];
    if (piece == null || piece.color != currentTurn) return [];

    List<Position> moves = [];
    switch (piece.type) {
      case PieceType.pawn:
        moves = _getPawnMoves(position);
        break;
      case PieceType.rook:
        moves = _getRookMoves(position);
        break;
      case PieceType.knight:
        moves = _getKnightMoves(position);
        break;
      case PieceType.bishop:
        moves = _getBishopMoves(position);
        break;
      case PieceType.queen:
        moves = _getQueenMoves(position);
        break;
      case PieceType.king:
        moves = _getKingMoves(position);
        break;
    }

    return moves.where((move) => !_wouldBeInCheck(position, move)).toList();
  }

  List<Position> _getPawnMoves(Position position) {
    List<Position> moves = [];
    final piece = board[position.row][position.col]!;
    final direction = piece.color == PieceColor.white ? -1 : 1;
    final startRow = piece.color == PieceColor.white ? 6 : 1;

    // Forward move
    if (_isValidPosition(position.row + direction, position.col) &&
        board[position.row + direction][position.col] == null) {
      moves.add(Position(position.row + direction, position.col));

      // Double move from starting position
      if (position.row == startRow &&
          _isValidPosition(position.row + 2 * direction, position.col) &&
          board[position.row + 2 * direction][position.col] == null) {
        moves.add(Position(position.row + 2 * direction, position.col));
      }
    }

    // Regular captures
    for (int colOffset in [-1, 1]) {
      final targetCol = position.col + colOffset;
      if (_isValidPosition(position.row + direction, targetCol)) {
        final targetPiece = board[position.row + direction][targetCol];
        if (targetPiece != null && targetPiece.color != piece.color) {
          moves.add(Position(position.row + direction, targetCol));
        }
      }
    }

    // En passant capture
    if (enPassantTarget != null) {
      final enPassantRow = piece.color == PieceColor.white ? 3 : 4;
      if (position.row == enPassantRow) {
        for (int colOffset in [-1, 1]) {
          if (position.col + colOffset == enPassantTarget!.col &&
              enPassantTarget!.row == position.row) {
            moves.add(Position(position.row + direction, enPassantTarget!.col));
          }
        }
      }
    }

    return moves;
  }

  List<Position> _getRookMoves(Position position) {
    List<Position> moves = [];
    final piece = board[position.row][position.col]!;

    // Horizontal and vertical moves
    final directions = [
      [0, 1], // right
      [0, -1], // left
      [1, 0], // down
      [-1, 0], // up
    ];

    for (var direction in directions) {
      var row = position.row + direction[0];
      var col = position.col + direction[1];

      while (_isValidPosition(row, col)) {
        final targetPiece = board[row][col];
        if (targetPiece == null) {
          moves.add(Position(row, col));
        } else {
          if (targetPiece.color != piece.color) {
            moves.add(Position(row, col));
          }
          break;
        }
        row += direction[0];
        col += direction[1];
      }
    }

    return moves;
  }

  List<Position> _getKnightMoves(Position position) {
    List<Position> moves = [];
    final piece = board[position.row][position.col]!;

    final possibleMoves = [
      [-2, -1],
      [-2, 1],
      [-1, -2],
      [-1, 2],
      [1, -2],
      [1, 2],
      [2, -1],
      [2, 1],
    ];

    for (var move in possibleMoves) {
      final row = position.row + move[0];
      final col = position.col + move[1];

      if (_isValidPosition(row, col)) {
        final targetPiece = board[row][col];
        if (targetPiece == null || targetPiece.color != piece.color) {
          moves.add(Position(row, col));
        }
      }
    }

    return moves;
  }

  List<Position> _getBishopMoves(Position position) {
    List<Position> moves = [];
    final piece = board[position.row][position.col]!;

    final directions = [
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1],
    ];

    for (var direction in directions) {
      var row = position.row + direction[0];
      var col = position.col + direction[1];

      while (_isValidPosition(row, col)) {
        final targetPiece = board[row][col];
        if (targetPiece == null) {
          moves.add(Position(row, col));
        } else {
          if (targetPiece.color != piece.color) {
            moves.add(Position(row, col));
          }
          break;
        }
        row += direction[0];
        col += direction[1];
      }
    }

    return moves;
  }

  List<Position> _getQueenMoves(Position position) {
    return [..._getRookMoves(position), ..._getBishopMoves(position)];
  }

  List<Position> _getKingMoves(Position position) {
    List<Position> moves = [];
    final piece = board[position.row][position.col]!;

    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue;

        final row = position.row + i;
        final col = position.col + j;

        if (_isValidPosition(row, col)) {
          final targetPiece = board[row][col];
          if (targetPiece == null || targetPiece.color != piece.color) {
            moves.add(Position(row, col));
          }
        }
      }
    }

    // Add castling moves if king hasn't moved
    if (!piece.hasMoved) {
      // Kingside castling
      if (_canCastle(position, true)) {
        moves.add(Position(position.row, position.col + 2));
      }
      // Queenside castling
      if (_canCastle(position, false)) {
        moves.add(Position(position.row, position.col - 2));
      }
    }

    return moves;
  }

  bool _canCastle(Position kingPos, bool isKingside) {
    final row = kingPos.row;
    final rookCol = isKingside ? 7 : 0;
    final rook = board[row][rookCol];

    if (rook == null || rook.type != PieceType.rook || rook.hasMoved) {
      return false;
    }

    final direction = isKingside ? 1 : -1;
    final endCol = isKingside ? 6 : 2;

    for (int col = kingPos.col + direction; col != endCol; col += direction) {
      if (board[row][col] != null) {
        return false;
      }
    }

    return true;
  }

  bool _isValidPosition(int row, int col) {
    return row >= 0 && row < boardSize && col >= 0 && col < boardSize;
  }

  bool _wouldBeInCheck(Position from, Position to) {
    // Create a temporary board state
    final tempBoard = List.generate(
      boardSize,
      (i) => List.generate(
        boardSize,
        (j) => board[i][j]?.copyWith(hasMoved: board[i][j]?.hasMoved ?? false),
      ),
    );

    // Make the move
    tempBoard[to.row][to.col] = tempBoard[from.row][from.col];
    tempBoard[from.row][from.col] = null;

    // Check if the king is in check
    return _isInCheck(currentTurn, tempBoard);
  }

  // Add this method to find the king's position
  Position? findKingPosition(PieceColor color, [List<List<ChessPiece?>>? boardState]) {
    final state = boardState ?? board;
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        final piece = state[i][j];
        if (piece?.type == PieceType.king && piece?.color == color) {
          return Position(i, j);
        }
      }
    }
    return null;
  }

  // Add this method to check if a king is in check
  bool isKingInCheck(PieceColor color) {
    return _isInCheck(color, board);
  }

  bool _isInCheck(PieceColor color, List<List<ChessPiece?>> boardState) {
    // Find the king's position
    Position? kingPos;
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        final piece = boardState[i][j];
        if (piece?.type == PieceType.king && piece?.color == color) {
          kingPos = Position(i, j);
          break;
        }
      }
      if (kingPos != null) break;
    }

    if (kingPos == null) return false;

    // Check if any opponent piece can capture the king
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        final piece = boardState[i][j];
        if (piece != null && piece.color != color) {
          final moves = _getPieceMoves(Position(i, j), boardState);
          if (moves.contains(kingPos)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  List<Position> _getPieceMoves(
    Position position,
    List<List<ChessPiece?>> boardState,
  ) {
    final piece = boardState[position.row][position.col];
    if (piece == null) return [];

    switch (piece.type) {
      case PieceType.pawn:
        return _getPawnMoves(position);
      case PieceType.rook:
        return _getRookMoves(position);
      case PieceType.knight:
        return _getKnightMoves(position);
      case PieceType.bishop:
        return _getBishopMoves(position);
      case PieceType.queen:
        return _getQueenMoves(position);
      case PieceType.king:
        return _getKingMoves(position);
    }
  }

  void makeMove(Position from, Position to) {
    final piece = board[from.row][from.col]!;
    
    // Reset en passant target
    Position? newEnPassantTarget;
    
    // Set en passant target if pawn moves two squares
    if (piece.type == PieceType.pawn && (to.row - from.row).abs() == 2) {
      newEnPassantTarget = Position((from.row + to.row) ~/ 2, from.col);
    }
    
    // Handle en passant capture
    if (piece.type == PieceType.pawn && 
        to.col != from.col && 
        board[to.row][to.col] == null) {
      // This is an en passant capture
      board[from.row][to.col] = null; // Remove the captured pawn
    }
    
    board[to.row][to.col] = piece.copyWith(hasMoved: true);
    board[from.row][from.col] = null;

    // Handle pawn promotion
    if (piece.type == PieceType.pawn && (to.row == 0 || to.row == 7)) {
      board[to.row][to.col] = ChessPiece(
        type: PieceType.queen,
        color: piece.color,
        hasMoved: true,
      );
    }

    // Handle castling
    if (piece.type == PieceType.king && (to.col - from.col).abs() == 2) {
      final isKingside = to.col > from.col;
      final rookCol = isKingside ? 7 : 0;
      final newRookCol = isKingside ? to.col - 1 : to.col + 1;

      board[to.row][newRookCol] = board[to.row][rookCol]?.copyWith(
        hasMoved: true,
      );
      board[to.row][rookCol] = null;
    }

    enPassantTarget = newEnPassantTarget;
    currentTurn =
        currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    selectedPiece = null;
    validMoves = [];

    // Check for checkmate or stalemate
    _checkGameEnd();
  }

  void _checkGameEnd() {
    bool hasLegalMoves = false;
    
    // Check if the current player is in check
    bool inCheck = isKingInCheck(currentTurn);
    
    // Check if any piece has legal moves
    for (int i = 0; i < boardSize && !hasLegalMoves; i++) {
      for (int j = 0; j < boardSize && !hasLegalMoves; j++) {
        final piece = board[i][j];
        if (piece?.color == currentTurn) {
          final moves = getValidMoves(Position(i, j));
          if (moves.isNotEmpty) {
            hasLegalMoves = true;
            break;
          }
        }
      }
    }

    if (!hasLegalMoves) {
      isGameOver = true;
      if (inCheck) {
        // Checkmate
        winner = currentTurn == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;
      } else {
        // Stalemate - no winner
        winner = null;
      }
    }
  }

  void reset() {
    board = List.generate(
      boardSize,
      (i) => List.generate(boardSize, (j) => null),
    );
    currentTurn = PieceColor.white;
    selectedPiece = null;
    validMoves = [];
    isGameOver = false;
    winner = null;
    _initializeBoard();
  }
}
