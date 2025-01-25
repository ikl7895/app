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

    testWidgets('GameBoard should have restart button', (WidgetTester tester) async {
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

    test('Game should not be over at start', () {
      expect(gameLogic.gameOver, false);
    });

    test('Board should have two non-zero tiles at start', () {
      int nonZeroTiles = 0;
      for (var row in gameLogic.board) {
        for (var tile in row) {
          if (tile != 0) nonZeroTiles++;
        }
      }
      expect(nonZeroTiles, 2);
    });

    test('Reset should clear board and add two new tiles', () {
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
}
