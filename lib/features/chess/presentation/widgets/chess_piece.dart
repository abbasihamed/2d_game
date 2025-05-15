import 'package:two_d_game/core/enums.dart';

class ChessPiece {
  final PieceType type;
  final PieceColor color;
  bool hasMoved;

  ChessPiece({required this.type, required this.color, this.hasMoved = false});

  String get imagePath {
    final colorPrefix = color == PieceColor.white ? 'w' : 'b';
    final typeName = type.toString().split('.').last;
    return 'assets/images/chess/$colorPrefix$typeName.png';
  }

  ChessPiece copyWith({PieceType? type, PieceColor? color, bool? hasMoved}) {
    return ChessPiece(
      type: type ?? this.type,
      color: color ?? this.color,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }
}
