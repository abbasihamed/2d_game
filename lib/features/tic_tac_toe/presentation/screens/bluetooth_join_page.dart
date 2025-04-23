import 'package:flutter/material.dart';

class BluetoothJoinPage extends StatelessWidget {
  final GameType gameType;
  const BluetoothJoinPage({super.key, required this.gameType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Game')),
      body: BlocBuilder<BluetoothBloc, BluetoothState>(
        builder: (context, state) {
          if (state is Scanning) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScanSuccess) {
            final results = state.results;
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final device = results[index].device;
                return ListTile(
                  title: Text(device.name.isEmpty ? device.id.id : device.name),
                  subtitle: Text(device.id.id),
                  onTap: () {
                    // context.read<BluetoothBloc>().add(
                    //   ConnectRequested(results[index]),
                    // );
                  },
                );
              },
            );
          } else if (state is Connecting) {
            return const Center(child: Text('Connecting...'));
          } else if (state is Connected) {
            // Navigate to game on connection
          //   WidgetsBinding.instance.addPostFrameCallback((_) {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(
          //         builder: (_) {
          //           return (gameType == GameType.classic)
          //               ? GamePage(mode: GameMode.twoPlayerBluetooth)
          //               : UltimateGamePage(singlePlayer: false);
          //         },
          //       ),
          //     );
          //   });
          //   return const Center(child: Text('Connected!'));
          // } else if (state is BluetoothError) {
          //   return Center(child: Text('Error: ${state.message}'));
          // }
          return const SizedBox();
        },
      ),
    );
  }
}
