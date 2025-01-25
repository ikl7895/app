import 'package:flutter/material.dart';
import '../widgets/game_board.dart';
import '../providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class Game2048Screen extends StatelessWidget {
  const Game2048Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const Text('game'),
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            context.read<NavigationProvider>().setIndex(0);
          },
        ),
      ),
      body: const SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GameBoard(),
            ),
          ],
        ),
      ),
    );
  }
} 