import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'game_tile.dart';
import '../models/game_logic.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late final GameLogic gameLogic;
  StreamSubscription? _accelerometerSubscription;
  DateTime? _lastShakeTime;

  @override
  void initState() {
    super.initState();
    gameLogic = GameLogic();
    _initAccelerometer();
  }

  void _initAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      double acceleration = event.x * event.x +
          event.y * event.y +
          event.z * event.z;

      if (acceleration > 100) {
        final now = DateTime.now();
        if (_lastShakeTime == null ||
            now.difference(_lastShakeTime!) > const Duration(seconds: 1)) {
          _lastShakeTime = now;
          _showResetConfirmation();
        }
      }
    });
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Game'),
        content: const Text('Are you sure you want to restart the game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void resetGame() {
    setState(() {
      gameLogic.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score: ${gameLogic.score}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showResetConfirmation(),
                    child: const Text('Restart'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Hint: Shake your phone to reset the game',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: GestureDetector(
              onHorizontalDragEnd: move,
              onVerticalDragEnd: move,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      final i = index ~/ 4;
                      final j = index % 4;
                      return GameTile(value: gameLogic.board[i][j]);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        if (gameLogic.gameOver)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Game Over! Final Score: ${gameLogic.score}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  void move(DragEndDetails details) {
    if (gameLogic.gameOver) return;

    final dx = details.velocity.pixelsPerSecond.dx;
    final dy = details.velocity.pixelsPerSecond.dy;
    
    print('dx: $dx, dy: $dy');

    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        print('Moving right');
        gameLogic.moveRight();
      } else {
        print('Moving left');
        gameLogic.moveLeft();
      }
    } else {
      if (dy > 0) {
        print('Moving down');
        gameLogic.moveDown();
        setState(() {});
      } else {
        print('Moving up');
        gameLogic.moveUp();
      }
    }

    setState(() {
      gameLogic.gameOver = !gameLogic.canMove();
    });
  }
}
