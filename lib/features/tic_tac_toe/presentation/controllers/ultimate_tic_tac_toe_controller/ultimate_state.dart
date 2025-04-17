part of 'ultimate_bloc.dart';

class UltimateState {
  final List<List<Player?>> localBoards;
  final List<BoardResult> localResults;
  final int forcedBoard;
  final Player currentPlayer;
  final UltimateResult gameResult;
  const UltimateState({
    required this.localBoards,
    required this.localResults,
    required this.forcedBoard,
    required this.currentPlayer,
    required this.gameResult,
  });
  factory UltimateState.initial() => UltimateState(
    localBoards: List.generate(9, (_) => List.filled(9, null)),
    localResults: List.filled(9, BoardResult.ongoing),
    forcedBoard: -1,
    currentPlayer: Player.X,
    gameResult: UltimateResult.ongoing,
  );
}
