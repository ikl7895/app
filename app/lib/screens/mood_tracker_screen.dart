import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';
import '../screens/chat_screen.dart';
import 'game_2048_screen.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({Key? key}) : super(key: key);

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  int _currentQuestionIndex = 0;
  int _totalScore = 0;
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'How do you feel today?',
      'answers': [
        {'text': 'Very Good', 'score': 5},
        {'text': 'Pretty Good', 'score': 4},
        {'text': 'Okay', 'score': 3},
        {'text': 'A bit down', 'score': 2},
        {'text': 'Very Bad', 'score': 1},
      ],
    },
    {
      'question': 'How was your sleep quality?',
      'answers': [
        {'text': 'Slept very well', 'score': 5},
        {'text': 'Slept okay', 'score': 4},
        {'text': 'Average', 'score': 3},
        {'text': 'Not so good', 'score': 2},
        {'text': 'Could not sleep', 'score': 1},
      ],
    },
    {
      'question': 'How stressful was your work/study today?',
      'answers': [
        {'text': 'Very relaxed', 'score': 5},
        {'text': 'Manageable', 'score': 4},
        {'text': 'Average', 'score': 3},
        {'text': 'A bit stressful', 'score': 2},
        {'text': 'Extremely stressful', 'score': 1},
      ],
    },
    {
      'question': 'How was your interaction with others?',
      'answers': [
        {'text': 'Very pleasant', 'score': 5},
        {'text': 'Quite pleasant', 'score': 4},
        {'text': 'Okay', 'score': 3},
        {'text': 'A bit unpleasant', 'score': 2},
        {'text': 'Very unpleasant', 'score': 1},
      ],
    },
    {
      'question': 'How hopeful are you about the future?',
      'answers': [
        {'text': 'Very hopeful', 'score': 5},
        {'text': 'Somewhat hopeful', 'score': 4},
        {'text': 'Neutral', 'score': 3},
        {'text': 'A bit worried', 'score': 2},
        {'text': 'Very worried', 'score': 1},
      ],
    },
  ];

  void _answerQuestion(int score) {
    setState(() {
      _totalScore += score;
      _currentQuestionIndex++;
    });

    if (_currentQuestionIndex >= _questions.length) {
      _showResult();
    }
  }

  void _showResult() {
    final double averageScore = _totalScore / _questions.length;
    final bool isGoodMood = averageScore >= 3.5;

    // Save mood record
    final entry = JournalEntry(
      id: DateTime.now().toString(),
      title: 'Daily Mood Survey',
      content: 'Completed the daily mood survey.',
      date: DateTime.now(),
      mood: averageScore.toStringAsFixed(1),
      type: JournalEntry.TYPE_MOOD_SURVEY,
    );

    // Save to JournalProvider
    context.read<JournalProvider>().addEntry(entry);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          isGoodMood ? 'Feeling Great!' : 'Time to Relax',
          style: TextStyle(
            color: isGoodMood ? Colors.green : Colors.orange,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your mood score: ${averageScore.toStringAsFixed(1)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isGoodMood
                  ? 'Great! Keep up the good mood!'
                  : 'Why not try these to relax:',
            ),
            if (!isGoodMood) ...[
              const SizedBox(height: 20),
              _buildOptionButton(
                'Try Meditation',
                Icons.self_improvement,
                    () {
                  Navigator.pop(context);
                  context.read<NavigationProvider>().setIndex(2);
                },
              ),
              const SizedBox(height: 10),
              _buildOptionButton(
                'Talk to Someone',
                Icons.chat_bubble_outline,
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildOptionButton(
                'Play a Game',
                Icons.games,
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Game2048Screen(),
                    ),
                  );
                },
              ),
            ] else ...[
              const SizedBox(height: 20),
              _buildOptionButton(
                'Return to Home',
                Icons.home,
                    () {
                  Navigator.pop(context);
                  context.read<NavigationProvider>().setIndex(0);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(text),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
      ),
      body: _currentQuestionIndex < _questions.length
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _questions[_currentQuestionIndex]['question'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ..._questions[_currentQuestionIndex]['answers']
                .map<Widget>((answer) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  onPressed: () => _answerQuestion(answer['score']),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(answer['text']),
                ),
              );
            }).toList(),
          ],
        ),
      )
          : Center(
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _currentQuestionIndex = 0;
              _totalScore = 0;
            });
          },
          child: const Text('Start Survey'),
        ),
      ),
    );
  }
}
