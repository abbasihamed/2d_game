part of 'ultimate_bloc.dart';

sealed class UltimateEvent {}

class UltimateCellTapped extends UltimateEvent {
  final int lb, idx;
  UltimateCellTapped(this.lb, this.idx);
}

class UltimateReset extends UltimateEvent {}
