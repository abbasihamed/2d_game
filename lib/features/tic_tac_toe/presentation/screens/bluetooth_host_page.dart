import 'package:flutter/material.dart';
import 'package:tictactoe/features/tic_tac_toe/presentation/screens/ultimate_game_page.dart';

class BluetoothHostPage extends StatelessWidget {
  final GameType gameType;
  const BluetoothHostPage({super.key, required this.gameType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hosting...')),
      body: BlocConsumer<BluetoothBloc, BluetoothState>(
        listener: (context, state) {
          // if (state is Connected) {
          //   Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) {
          //         return (gameType == GameType.classic)
          //             ? GamePage(mode: GameMode.twoPlayerBluetooth)
          //             : UltimateGamePage(playerMode: PlayerMode.single);
          //       },
          //     ),
          //   );
          // }
        },
        builder: (context, state) {
          // if (state is Scanning) {
          //   return const Center(child: CircularProgressIndicator());
          // } else if (state is ScanSuccess) {
          //   // Host picks first discovered device
          //   final device = state.results.first.device;
          //   context.read<BluetoothBloc>().add(ConnectRequested(state.results.first));
          //   return Center(child: Text('Connecting to ${device.name}...'));
          // } else if (state is Connecting) {
          //   return const Center(child: Text('Waiting for join...'));
          // } else if (state is BluetoothError) {
          //   return Center(child: Text('Error: ${state.message}'));
          // }
          return const Center(child: Text('Initializing...'));
        },
      ),
    );
  }
}