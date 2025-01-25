import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/game_board.dart';
import 'package:app/widgets/game_tile.dart';
import 'package:app/models/game_logic.dart';

void main() {
  group('GameBoard Widget Tests', () {
    testWidgets('GameBoard should initialize with two tiles', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameBoard()));

      // Check if there are two non-zero tiles
      final tiles = tester.widgetList<GameTile>(find.byType(GameTile));
      int nonZeroTiles = 0;
      for (var tile in tiles) {
        if (tile.value != 0) nonZeroTiles++;
      }
      expect(nonZeroTiles, 2);
    });

    testWidgets('GameBoard should show score', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameBoard()));

      // Check if score is displayed
      expect(find.textContaining('Score:'), findsOneWidget);
    });

    testWidgets('GameBoard should have a restart button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameBoard()));

      // Check if restart button exists
      expect(find.text('Restart'), findsOneWidget);
    });

    testWidgets('Restart button should show confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameBoard()));

      // Tap the restart button
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();

      // Check if confirmation dialog appears
      expect(find.text('Reset Game'), findsOneWidget);
      expect(find.text('Are you sure you want to restart the game?'), findsOneWidget);
    });
  });

  group('GameTile Widget Tests', () {
    testWidgets('GameTile should display correct value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameTile(value: 2),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('GameTile should be empty when value is 0', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameTile(value: 0),
          ),
        ),
      );

      expect(find.text('0'), findsNothing);
    });
  });

  group('Game Logic Tests', () {
    late GameLogic gameLogic;

    setUp(() {
      gameLogic = GameLogic();
    });

    test('Board should initialize correctly', () {
      expect(gameLogic.board.length, 4);
      expect(gameLogic.board[0].length, 4);
    });

    test('Score should start at 0', () {
      expect(gameLogic.score, 0);
    });

    test('Game should not be over at the start', () {
      expect(gameLogic.gameOver, false);
    });

    test('Board should have two non-zero tiles at the start', () {
      int nonZeroTiles = 0;
      for (var row in gameLogic.board) {
        for (var tile in row) {
          if (tile != 0) nonZeroTiles++;
        }
      }
      expect(nonZeroTiles, 2);
    });

    test('Reset should clear the board and add two new tiles', () {
      gameLogic.score = 100;
      gameLogic.reset();

      expect(gameLogic.score, 0);

      int nonZeroTiles = 0;
      for (var row in gameLogic.board) {
        for (var tile in row) {
          if (tile != 0) nonZeroTiles++;
        }
      }
      expect(nonZeroTiles, 2);
    });
  });

  group('GameLogic Unit Tests', () {
    late GameLogic gameLogic;

    setUp(() {
      gameLogic = GameLogic();
    });

    test('Initial board state', () {
      int nonZeroTiles = 0;
      for (var row in gameLogic.board) {
        for (var tile in row) {
          if (tile != 0) nonZeroTiles++;
          expect(tile == 0 || tile == 2 || tile == 4, true);
        }
      }
      expect(nonZeroTiles, 2);
      expect(gameLogic.score, 0);
      expect(gameLogic.gameOver, false);
    });

    test('Move left functionality', () {
      gameLogic.board = [
        [2, 2, 0, 0],
        [2, 0, 2, 0],
        [4, 0, 4, 0],
        [0, 0, 0, 2],
      ];

      gameLogic.moveLeft();

      expect(gameLogic.board[0][0], 4);
      expect(gameLogic.board[1][0], 4);
      expect(gameLogic.board[2][0], 8);
      expect(gameLogic.board[3][0], 2);
    });

    test('Move right functionality', () {
      gameLogic.board = [
        [0, 0, 2, 2],
        [0, 2, 0, 2],
        [0, 4, 0, 4],
        [2, 0, 0, 0],
      ];

      gameLogic.moveRight();

      expect(gameLogic.board[0][3], 4);
      expect(gameLogic.board[1][3], 4);
      expect(gameLogic.board[2][3], 8);
      expect(gameLogic.board[3][3], 2);
    });

    test('Move up functionality', () {
      gameLogic.board = [
        [2, 0, 4, 2],
        [2, 0, 4, 0],
        [0, 2, 0, 2],
        [0, 2, 0, 0],
      ];

      gameLogic.moveUp();

      expect(gameLogic.board[0][0], 4);
      expect(gameLogic.board[0][1], 4);
      expect(gameLogic.board[0][2], 8);
      expect(gameLogic.board[0][3], 4);
    });

    test('Move down functionality', () {
      gameLogic.board = [
        [2, 0, 4, 0],
        [2, 2, 4, 0],
        [0, 2, 0, 2],
        [0, 0, 0, 2],
      ];

      gameLogic.moveDown();

      expect(gameLogic.board[3][0], 4);
      expect(gameLogic.board[3][1], 4);
      expect(gameLogic.board[3][2], 8);
      expect(gameLogic.board[3][3], 4);
    });

    test('Game over detection', () {
      gameLogic.board = [
        [2, 4, 2, 4],
        [4, 2, 4, 2],
        [2, 4, 2, 4],
        [4, 2, 4, 2],
      ];

      expect(gameLogic.canMove(), false);
    });

    test('Score calculation', () {
      gameLogic.board = [
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];

      gameLogic.moveLeft();
      expect(gameLogic.score, 4);
    });
  });

  group('GameBoard Widget Integration Tests', () {
    testWidgets('Game board responds to gestures', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameBoard()));

      // Record the initial state
      final GameBoard gameBoard = tester.widget(find.byType(GameBoard));
      final initialBoard = List<List<int>>.from(gameBoard.createState().gameLogic.board);

      // Simulate left swipe
      await tester.drag(find.byType(GameBoard), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Check if the board has changed
      final currentBoard = gameBoard.createState().gameLogic.board;
      expect(initialBoard, isNot(equals(currentBoard)));
    });

    testWidgets('Reset functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameBoard()));

      // Tap the reset button
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();

      // Confirm the confirmation dialog appears
      expect(find.text('Reset Game'), findsOneWidget);
      expect(find.text('Are you sure you want to restart the game?'), findsOneWidget);

      // Confirm reset
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Check if score is reset
      expect(find.text('Score: 0'), findsOneWidget);
    });

    testWidgets('Game over state is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GameBoard()));

      final GameBoard gameBoard = tester.widget(find.byType(GameBoard));
      final state = gameBoard.createState() as dynamic;

      // Simulate game over state
      state.gameLogic.gameOver = true;
      await tester.pump();

      expect(find.textContaining('Game Over'), findsOneWidget);
    });
  });
}
