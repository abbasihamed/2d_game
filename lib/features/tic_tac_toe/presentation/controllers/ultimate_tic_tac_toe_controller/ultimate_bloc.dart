import 'package:bloc/bloc.dart';
import 'package:tictactoe/core/enums.dart';

part 'ultimate_event.dart';
part 'ultimate_state.dart';

class UltimateBloc extends Bloc<UltimateEvent, UltimateState> {
  UltimateBloc() : super(UltimateState.initial()) {
    on<UltimateCellTapped>(_onTap);
    on<UltimateReset>((e, emit) => emit(UltimateState.initial()));
  }

  void _onTap(UltimateCellTapped e, Emitter<UltimateState> em) {
    final s = state;
    if (s.gameResult != UltimateResult.ongoing) return;
    if (s.forcedBoard != -1 && e.lb != s.forcedBoard) return;
    var lb = List<List<Player?>>.from(s.localBoards);
    var lr = List<BoardResult>.from(s.localResults);
    if (lb[e.lb][e.idx] != null || lr[e.lb] != BoardResult.ongoing) return;
    lb[e.lb][e.idx] = s.currentPlayer;
    lr[e.lb] = checkLocalResult(lb[e.lb]);
    final nextForced = lr[e.idx] == BoardResult.ongoing ? e.idx : -1;
    final gr = checkGlobalResult(lr);
    em(
      UltimateState(
        localBoards: lb,
        localResults: lr,
        forcedBoard: nextForced,
        currentPlayer: s.currentPlayer == Player.X ? Player.O : Player.X,
        gameResult: gr,
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
