import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:two_d_game/core/enums.dart';
import 'package:two_d_game/features/chess/presentation/blocs/chess_bloc.dart';
import 'package:two_d_game/features/chess/presentation/widgets/captured_pieces_display.dart';
import 'package:two_d_game/features/chess/presentation/widgets/chess_board.dart';

class ChessScreen extends StatelessWidget {
  const ChessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChessBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chess'),
          actions: [
            BlocBuilder<ChessBloc, ChessState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<ChessBloc>().add(ChessGameReset());
                  },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ChessBloc, ChessState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.isGameOver)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      state.winner == null
                          ? 'Stalemate - Draw!'
                          : state.winner == PieceColor.white
                              ? 'White wins by checkmate!'
                              : 'Black wins by checkmate!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                CapturedPiecesDisplay(
                  capturedPieces: state.capturedBlackPieces,
                ),
                if (!state.isGameOver && state.board.isKingInCheck(state.board.currentTurn))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'CHECK!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ChessBoardWidget(
                        board: state.board,
                        selectedPiece: state.selectedPiece,
                        validMoves: state.validMoves,
                      ),
                    ),
                  ),
                ),
                CapturedPiecesDisplay(
                  capturedPieces: state.capturedWhitePieces,
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ChessBoardWidget extends StatelessWidget {
  final ChessBoard board;
  final Position? selectedPiece;
  final List<Position> validMoves;

  const ChessBoardWidget({
    super.key,
    required this.board,
    this.selectedPiece,
    this.validMoves = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Find kings in check
    final whiteKingInCheck = board.isKingInCheck(PieceColor.white);
    final blackKingInCheck = board.isKingInCheck(PieceColor.black);
    
    // Find king positions
    final whiteKingPos = board.findKingPosition(PieceColor.white);
    final blackKingPos = board.findKingPosition(PieceColor.black);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown, width: 2),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: 64,
        itemBuilder: (context, index) {
          final row = index ~/ 8;
          final col = index % 8;
          final isLightSquare = (row + col) % 2 == 0;
          final position = Position(row, col);
          final piece = board.board[row][col];
          final isSelected = selectedPiece == position;
          final isValidMove = validMoves.contains(position);
          
          // Check if this position contains a king in check
          final isKingInCheck = (whiteKingInCheck && position == whiteKingPos) || 
                               (blackKingInCheck && position == blackKingPos);

          return GestureDetector(
            onTap: () {
              if (piece != null && piece.color == board.currentTurn) {
                context.read<ChessBloc>().add(ChessPieceSelected(position));
              } else if (selectedPiece != null &&
                  validMoves.contains(position)) {
                context
                    .read<ChessBloc>()
                    .add(ChessMoveMade(selectedPiece!, position));
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: isLightSquare
                    ? const Color(0xFFF0D9B5) // Light square color
                    : const Color(0xFFB58863), // Dark square color
                border: Border.all(
                  color: isSelected
                      ? Colors.blue
                      : isValidMove
                          ? Colors.green
                          : isKingInCheck
                              ? Colors.red
                              : Colors.transparent,
                  width: isKingInCheck ? 3 : 2,
                ),
              ),
              child: piece != null
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: Stack(
                        children: [
                          Image.asset(
                            piece.imagePath,
                            fit: BoxFit.contain,
                          ),
                          if (isKingInCheck && piece.type == PieceType.king)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                        ],
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
