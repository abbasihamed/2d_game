import 'package:two_d_game/core/enums.dart';

List<int>? getWinningPattern(List<BoardResult> results) {
  const patterns = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];
  for (var p in patterns) {
    final a = results[p[0]];
    if (a == BoardResult.xWin || a == BoardResult.oWin) {
      if (results[p[1]] == a && results[p[2]] == a) {
        return p;
      }
    }
  }
  return null;
}