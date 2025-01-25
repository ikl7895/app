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
} 