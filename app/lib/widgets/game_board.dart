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
      // 計算加速度的總和
      double acceleration = event.x * event.x + 
                          event.y * event.y + 
                          event.z * event.z;
      
      // 如果加速度超過某個閾值，且距離上次搖動超過1秒
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
        title: const Text('重置遊戲'),
        content: const Text('確定要重新開始遊戲嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              resetGame();
            },
            child: const Text('確定'),
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

    final dx = details.velocity.pixelsPerSecond.dx;
    final dy = details.velocity.pixelsPerSecond.dy;
    
    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        moveRight();
      } else {
        moveLeft();
      }
    } else {
      if (dy > 0) {
        moveDown();
      } else {
        moveUp();
      }
    }

    setState(() {
      if (!canMove()) {
        gameOver = true;
      }
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
      
      for (int j = 1; j < row.length; j++) {
        if (row[j] == row[j - 1]) {
          row[j - 1] *= 2;
          score += row[j - 1];
          row.removeAt(j);
          moved = true;
        }
      }
      
      while (row.length < 4) {
        row.add(0);
      }
      
      if (row.toString() != board[i].toString()) {
        moved = true;
      }
      board[i] = row;
    }
    
    if (moved) {
      addNewTile();
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
      
      for (int j = 1; j < row.length; j++) {
        if (row[j] == row[j - 1]) {
          row[j - 1] *= 2;
          score += row[j - 1];
          row.removeAt(j);
          moved = true;
        }
      }
      
      while (row.length < 4) {
        row.insert(0, 0);
      }
      
      if (row.toString() != board[i].toString()) {
        moved = true;
      }
      board[i] = row;
    }
    
    if (moved) {
      addNewTile();
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
      
      for (int i = 1; i < column.length; i++) {
        if (column[i] == column[i - 1]) {
          column[i - 1] *= 2;
          score += column[i - 1];
          column.removeAt(i);
          moved = true;
        }
      }
      
      while (column.length < 4) {
        column.add(0);
      }
      
      for (int i = 0; i < 4; i++) {
        if (board[i][j] != column[i]) {
          moved = true;
        }
        board[i][j] = column[i];
      }
    }
    
    if (moved) {
      addNewTile();
    }
  }

  void moveDown() {
    bool moved = false;
    for (int j = 0; j < 4; j++) {
      List<int> column = [];
      for (int i = 3; i >= 0; i--) {
        if (board[i][j] != 0) {
          column.add(board[i][j]);
        }
      }
      
      for (int i = 1; i < column.length; i++) {
        if (column[i] == column[i - 1]) {
          column[i - 1] *= 2;
          score += column[i - 1];
          column.removeAt(i);
          moved = true;
        }
      }
      
      while (column.length < 4) {
        column.insert(0, 0);
      }
      
      for (int i = 0; i < 4; i++) {
        if (board[3 - i][j] != column[i]) {
          moved = true;
        }
        board[3 - i][j] = column[i];
      }
    }
    
    if (moved) {
      addNewTile();
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
                    '分數: $score',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showResetConfirmation(),
                    child: const Text('重新開始'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '提示：搖動手機可以重置遊戲',
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
              '遊戲結束！最終分數：$score',
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