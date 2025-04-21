import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tictactoe/features/tic_tac_toe/presentation/controllers/ultimate_tic_tac_toe_controller/ultimate_bloc.dart';

class UltimateBoardWidget extends StatelessWidget {
  final UltimateState state;
  const UltimateBoardWidget({super.key, required this.state});
  @override
  Widget build(BuildContext c) => GridView.builder(
    physics: NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
    itemCount: 9,
    itemBuilder: (_, bi) {
      final highlight = state.forcedBoard == -1 || state.forcedBoard == bi;
      return Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: highlight ? Colors.blue : Colors.grey),
        ),
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: 9,
          itemBuilder:
              (_, ci) => GestureDetector(
                onTap:
                    () =>
                        c.read<UltimateBloc>().add(UltimateCellTapped(bi, ci)),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Center(
                    child: Text(state.localBoards[bi][ci]?.name ?? ''),
                  ),
                ),
              ),
        ),
      );
    },
  );
}
