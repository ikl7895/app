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
      
      // Merge tiles
      for (int i = 0; i < column.length - 1; i++) {
        if (column[i] == column[i + 1]) {
          column[i] *= 2;
          score += column[i];
          column.removeAt(i + 1);
          moved = true;
        }
      }
      
      // Fill empty spaces
      while (column.length < 4) {
        column.insert(0, 0);
      }
      
      // Update board
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
}
