import 'package:flutter/material.dart';
import 'dart:async';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({Key? key}) : super(key: key);

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  bool _isRunning = false;
  int _selectedMinutes = 5;
  late int _remainingSeconds;
  Timer? _timer;

  final List<Map<String, int>> _presetTimes = [
    {'seconds': 5, 'display': 5}, // 5 seconds for testing
    {'minutes': 5, 'display': 5},
    {'minutes': 10, 'display': 10},
    {'minutes': 15, 'display': 15},
    {'minutes': 20, 'display': 20},
    {'minutes': 30, 'display': 30},
  ];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _selectedMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _showCompletionDialog();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meditation Complete'),
        content: const Text('Congratulations on completing today\'s meditation session!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select Meditation Duration',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: _presetTimes.map((time) {
                    final int displayTime = time['display']!;
                    final bool isSeconds = time.containsKey('seconds');
                    return ChoiceChip(
                      label: Text(
                        '$displayTime ${isSeconds ? 'Seconds' : 'Minutes'}',
                        style: TextStyle(
                          color: _selectedMinutes == displayTime && !isSeconds ||
                              (isSeconds && _remainingSeconds == displayTime)
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      selected: _selectedMinutes == displayTime && !isSeconds ||
                          (isSeconds && _remainingSeconds == displayTime),
                      selectedColor: Colors.blue,
                      backgroundColor: Colors.white,
                      onSelected: _isRunning ? null : (selected) {
                        if (selected) {
                          setState(() {
                            if (isSeconds) {
                              _selectedMinutes = 0;
                              _remainingSeconds = time['seconds']!;
                            } else {
                              _selectedMinutes = time['minutes']!;
                              _remainingSeconds = _selectedMinutes * 60;
                            }
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRunning ? Colors.orange : Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _isRunning ? 'Pause' : 'Start',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _resetTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Text(
                  'Tip: Find a quiet place, \nrelax your body, \nand focus on your breathing.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
