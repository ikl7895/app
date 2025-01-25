import 'dart:math';

class GameLogic {
  List<List<int>> board = List.generate(4, (_) => List.filled(4, 0));
  int score = 0;
  bool gameOver = false;

  GameLogic() {
    addNewTile();
    addNewTile();
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

  void reset() {
    board = List.generate(4, (_) => List.filled(4, 0));
    score = 0;
    gameOver = false;
    addNewTile();
    addNewTile();
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
    // Implement the logic for moving tiles to the right
  }

  void moveUp() {
    // Implement the logic for moving tiles upward
  }

  void moveDown() {
    // Implement the logic for moving tiles downward
  }
}
