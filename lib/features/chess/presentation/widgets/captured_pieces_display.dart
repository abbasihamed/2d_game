import 'package:flutter/material.dart';
import 'package:two_d_game/features/chess/presentation/widgets/chess_piece.dart';

class CapturedPiecesDisplay extends StatelessWidget {
  final List<ChessPiece> capturedPieces;

  const CapturedPiecesDisplay({super.key, required this.capturedPieces});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 4.0,
        direction: Axis.horizontal,
        runAlignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        textDirection: TextDirection.rtl,
        runSpacing: 4,
        children: capturedPieces.map((piece) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Image.asset(
              piece.imagePath,
              width: 30,
              height: 30,
            ),
          );
        }).toList(),
      ),
    );
  }
}
