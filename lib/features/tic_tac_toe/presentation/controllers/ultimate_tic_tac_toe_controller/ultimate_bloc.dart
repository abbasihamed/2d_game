import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:tictactoe/core/enums.dart';

part 'ultimate_event.dart';
part 'ultimate_state.dart';

class UltimateBloc extends Bloc<UltimateEvent, UltimateState> {
  final PlayerMode playerMode;
  UltimateBloc({this.playerMode = PlayerMode.two})
    : super(UltimateState.initial()) {
    on<UltimateCellTapped>(_onPlayerTap);
    on<UltimateReset>((e, emit) => emit(UltimateState.initial()));
  }

  Future<void> _onPlayerTap(
    UltimateCellTapped event,
    Emitter<UltimateState> emit,
  ) async {
    final s = state;
    // 1) ignore if game over or wrong board
    if (s.gameResult != UltimateResult.ongoing ||
        (s.forcedBoard != -1 && event.lb != s.forcedBoard)) {
      return;
    }

    // 2) apply human move
    var boards = List<List<Player?>>.from(s.localBoards);
    var results = List<BoardResult>.from(s.localResults);
    if (boards[event.lb][event.idx] != null ||
        results[event.lb] != BoardResult.ongoing) {
      return;
    }

    boards[event.lb][event.idx] = s.currentPlayer;
    results[event.lb] = checkLocalResult(boards[event.lb]);
    final nextForced =
        results[event.idx] == BoardResult.ongoing ? event.idx : -1;
    final global = checkGlobalResult(results);
    final nextPlayer = s.currentPlayer == Player.X ? Player.O : Player.X;

    emit(
      UltimateState(
        localBoards: boards,
        localResults: results,
        forcedBoard: nextForced,
        currentPlayer: nextPlayer,
        gameResult: global,
      ),
    );

    // 3) if single‑player and it's AI’s turn, schedule AI move
    if (playerMode == PlayerMode.single &&
        nextPlayer == Player.O &&
        global == UltimateResult.ongoing) {
      await Future.delayed(const Duration(milliseconds: 500));
      await _performAIMove(emit);
    }
  }

  Future<void> _performAIMove(Emitter<UltimateState> emit) async {
    final s = state;
    var boards = List<List<Player?>>.from(s.localBoards);
    var results = List<BoardResult>.from(s.localResults);

    // Determine which local board to play in:
    int target =
        s.forcedBoard != -1
            ? s.forcedBoard
            : (() {
              // Gather all ongoing boards:
              final ongoing = <int>[];
              for (var i = 0; i < results.length; i++) {
                if (results[i] == BoardResult.ongoing) ongoing.add(i);
              }
              // Pick one at random:
              return ongoing[Random().nextInt(ongoing.length)];
            })();

    // **New: pick a random empty cell** within that board:
    final emptyCells = <int>[];
    for (var i = 0; i < boards[target].length; i++) {
      if (boards[target][i] == null) emptyCells.add(i);
    }
    final chosenIndex =
        emptyCells[Random().nextInt(
          emptyCells.length,
        )]; // :contentReference[oaicite:0]{index=0}

    // Apply the AI move:
    boards[target][chosenIndex] = Player.O;
    results[target] = checkLocalResult(boards[target]);
    final nextForced =
        (results[chosenIndex] == BoardResult.ongoing) ? chosenIndex : -1;
    final global = checkGlobalResult(results);

    emit(
      UltimateState(
        localBoards: boards,
        localResults: results,
        forcedBoard: nextForced,
        currentPlayer: Player.X,
        gameResult: global,
      ),
    );
  }
}

BoardResult checkLocalResult(List<Player?> b) {
  const w = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];
  for (var p in w) {
    var a = b[p[0]];
    if (a != null && a == b[p[1]] && a == b[p[2]])
      return a == Player.X ? BoardResult.xWin : BoardResult.oWin;
  }
  return b.contains(null) ? BoardResult.ongoing : BoardResult.draw;
}

UltimateResult checkGlobalResult(List<BoardResult> l) {
  const w = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];
  for (var p in w) {
    var a = l[p[0]];
    if (a == BoardResult.xWin && a == l[p[1]] && a == l[p[2]])
      return UltimateResult.xWin;
    if (a == BoardResult.oWin && a == l[p[1]] && a == l[p[2]])
      return UltimateResult.oWin;
  }
  return l.every((e) => e != BoardResult.ongoing)
      ? UltimateResult.draw
      : UltimateResult.ongoing;
}
