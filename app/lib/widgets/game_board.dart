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
    bool moved = false;
    for (int i = 0; i < 4; i++) {
      List<int> row = [];
      for (int j = 0; j < 4; j++) {
        if (board[i][j] != 0) {
          row.add(board[i][j]);
        }
      }
      
      // Merge tiles
      for (int j = 1; j < row.length; j++) {
        if (row[j] == row[j - 1]) {
          row[j - 1] *= 2;
          score += row[j - 1];
          row.removeAt(j);
          moved = true;
        }
      }
      
      // Fill empty spaces
      while (row.length < 4) {
        row.add(0);
      }
      
      // Check if the board changed
      if (row.toString() != board[i].toString()) {
        moved = true;
      }
      board[i] = row;
    }
    
    if (moved) {
      addNewTile();
      setState(() {});
    }
  }

  void moveRight() {
    bool moved = false;
    for (int i = 0; i < 4; i++) {
      List<int> row = [];
      for (int j = 3; j >= 0; j--) {
        if (board[i][j] != 0) {
          row.add(board[i][j]);
        }
      }
      
      // Merge tiles
      for (int j = 1; j < row.length; j++) {
        if (row[j] == row[j - 1]) {
          row[j - 1] *= 2;
          score += row[j - 1];
          row.removeAt(j);
          moved = true;
        }
      }
      
      // Fill empty spaces
      while (row.length < 4) {
        row.insert(0, 0);
      }
      
      // Check if the board changed
      if (row.toString() != board[i].toString()) {
        moved = true;
      }
      board[i] = row;
    }
    
    if (moved) {
      addNewTile();
      setState(() {});
    }
  }

  void moveUp() {
    bool moved = false;
    for (int j = 0; j < 4; j++) {
      List<int> column = [];
      for (int i = 0; i < 4; i++) {
        if (board[i][j] != 0) {
          column.add(board[i][j]);
        }
      }
      
      // Merge tiles
      for (int i = 1; i < column.length; i++) {
        if (column[i] == column[i - 1]) {
          column[i - 1] *= 2;
          score += column[i - 1];
          column.removeAt(i);
          moved = true;
        }
      }
      
      // Fill empty spaces
      while (column.length < 4) {
        column.add(0);
      }
      
      // Update board
      for (int i = 0; i < 4; i++) {
        if (board[i][j] != column[i]) {
          moved = true;
        }
        board[i][j] = column[i];
      }
    }
    
    if (moved) {
      addNewTile();
      setState(() {});
    }
  }

  void moveDown() {
    bool moved = false;
    
    // Start from the bottom and process each row upwards
    for (int j = 0; j < 4; j++) {
      for (int i = 2; i >= 0; i--) {
        if (board[i][j] != 0) {
          int row = i;
          // Move down until hitting another number or the boundary
          while (row + 1 < 4 && board[row + 1][j] == 0) {
            board[row + 1][j] = board[row][j];
            board[row][j] = 0;
            row++;
            moved = true;
          }
          // Check if merging is possible
          if (row + 1 < 4 && board[row + 1][j] == board[row][j]) {
            board[row + 1][j] *= 2;
            score += board[row + 1][j];
            board[row][j] = 0;
            moved = true;
          }
        }
      }
    }

    if (moved) {
      addNewTile();
      setState(() {});
    }
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
