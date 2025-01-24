import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'game_tile.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  List<List<int>> board = List.generate(4, (_) => List.filled(4, 0));
  int score = 0;
  bool gameOver = false;
  StreamSubscription? _accelerometerSubscription;
  DateTime? _lastShakeTime;

  @override
  void initState() {
    super.initState();
    addNewTile();
    addNewTile();
    _initAccelerometer();
  }

  void _initAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      // Calculate the total acceleration
      double acceleration = event.x * event.x +
          event.y * event.y +
          event.z * event.z;

      // Trigger reset if the acceleration exceeds a threshold and the last shake was more than 1 second ago
      if (acceleration > 250) {
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

  void addNewTile() {
    List<Point<int>> emptyTiles = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j] == 0) {
          emptyTiles.add(Point(i, j));
        }
      }
    }

    if (emptyTiles.isEmpty) return;

    final random = Random();
    final randomTile = emptyTiles[random.nextInt(emptyTiles.length)];
    board[randomTile.x][randomTile.y] = random.nextDouble() < 0.9 ? 2 : 4;
  }

  bool canMove() {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (board[i][j] == 0) return true;
        if (i < 3 && board[i][j] == board[i + 1][j]) return true;
        if (j < 3 && board[i][j] == board[i][j + 1]) return true;
      }
    }
    return false;
  }

  void move(DragEndDetails details) {
    if (gameOver) return;

    // Calculate the main direction of movement
    final dx = details.velocity.pixelsPerSecond.dx;
    final dy = details.velocity.pixelsPerSecond.dy;

    // Use absolute values to determine whether it's horizontal or vertical
    if (dx.abs() > dy.abs()) {
      // Horizontal movement
      if (dx > 0) {
        moveRight();
      } else {
        moveLeft();
      }
    } else {
      // Vertical movement
      if (dy > 0) {
        moveDown(); // Swipe down
      } else {
        moveUp(); // Swipe up
      }
    }

    // Check if the game is over
    setState(() {
      gameOver = !canMove();
    });
  }

  void moveLeft() {
    // Code remains unchanged (logic and functionality)
  }

  void moveRight() {
    // Code remains unchanged (logic and functionality)
  }

  void moveUp() {
    // Code remains unchanged (logic and functionality)
  }

  void moveDown() {
    // Code remains unchanged (logic and functionality)
  }

  void resetGame() {
    setState(() {
      board = List.generate(4, (_) => List.filled(4, 0));
      score = 0;
      gameOver = false;
      addNewTile();
      addNewTile();
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
                    'Score: $score',
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
                      return GameTile(value: board[i][j]);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        if (gameOver)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Game Over! Final Score: $score',
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
}
