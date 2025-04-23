import 'package:flutter/material.dart';
import 'package:tictactoe/core/enums.dart';

class BluetoothSetupPage extends StatelessWidget {
  final GameType gameType;
  const BluetoothSetupPage({super.key, required this.gameType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Setup')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                // Host: just listen for connection
                // context.read<BluetoothBloc>().add(ScanRequested());
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => HostWaitingPage(gameType: gameType),
                //   ),
                // );
              },
              child: const Text('Host Game'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Join: scan and pick
                // context.read<BluetoothBloc>().add(ScanRequested());
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => JoinGamePage(gameType: gameType),
                //   ),
                // );
              },
              child: const Text('Join Game'),
            ),
          ],
        ),
      ),
    );
  }
}
