import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/chess_bloc.dart';
import '../widgets/chess_board.dart';
import '../widgets/chess_piece.dart';

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
                      state.winner == PieceColor.white
                          ? 'White wins!'
                          : 'Black wins!',
                      style: Theme.of(context).textTheme.headlineMedium,
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
                          : Colors.transparent,
                  width: 2,
                ),
              ),
              child: piece != null
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        piece.imagePath,
                        fit: BoxFit.contain,
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
