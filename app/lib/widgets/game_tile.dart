import 'package:flutter/material.dart';

class GameTile extends StatelessWidget {
  final int value;

  const GameTile({Key? key, required this.value}) : super(key: key);

  Color get tileColor {
    switch (value) {
      case 2:
        return Colors.blue[50]!;
      case 4:
        return Colors.blue[100]!;
      case 8:
        return Colors.blue[200]!;
      case 16:
        return Colors.blue[300]!;
      case 32:
        return Colors.blue[400]!;
      case 64:
        return Colors.blue[500]!;
      case 128:
        return Colors.blue[600]!;
      case 256:
        return Colors.blue[700]!;
      case 512:
        return Colors.blue[800]!;
      case 1024:
        return Colors.blue[900]!;
      case 2048:
        return Colors.amber;
      default:
        return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          value == 0 ? '' : value.toString(),
          style: TextStyle(
            fontSize: value < 100 ? 32 : value < 1000 ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: value < 8 ? Colors.grey[800] : Colors.white,
          ),
        ),
      ),
    );
  }
} 