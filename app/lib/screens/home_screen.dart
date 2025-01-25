import 'package:flutter/material.dart';
import 'dart:math';
import '../main.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/journal_provider.dart';
import '../screens/statistics_screen.dart';
import '../models/journal_entry.dart';
import '../screens/chat_screen.dart';
import '../screens/game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Motivational Quotes
  static const List<String> _motivationalQuotes = [
    'Keep an optimistic attitude. Every day is a new beginning!',
    'Accept your current emotions and find peace in your mind.',
    'Every challenge in life is an opportunity to grow.',
    'Be kind to yourself and give yourself a moment of self-hug.',
    'Face life with a smile and enjoy every beautiful moment.',
    'Believe in yourself. You are stronger than you think.',
    'Enjoy moments of solitude and recharge your spirit.',
    'Everyone is on their own journey. No need to compare yourself with others.',
    'Seize the moment and live in the present.',
    'Every moment in life is worth being thankful for.',
  ];

  late String _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = _getRandomQuote();
  }

  String _getRandomQuote() {
    final random = Random();
    return _motivationalQuotes[random.nextInt(_motivationalQuotes.length)];
  }

  void _navigateToPage(BuildContext context, int index) {
    context.read<NavigationProvider>().setIndex(index);
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Records'),
        content: const Text('Are you sure you want to clear all mood records? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<JournalProvider>().clearAllEntries();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All records have been cleared')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Confirm Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEntryItem(JournalEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${entry.date.year}/${entry.date.month}/${entry.date.day} ${entry.date.hour}:${entry.date.minute}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (entry.type == JournalEntry.TYPE_MOOD_SURVEY)
            Text(
              '${entry.mood} Points',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              entry.mood,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Garden'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showClearConfirmDialog,
            tooltip: 'Clear All Records',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Motivational Quotes Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Motivational Quote',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentQuote,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Quick Actions Section
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _buildQuickActionCard(
                  context,
                  'Record Mood',
                  Icons.mood,
                  Colors.blue[100]!,
                      () => _navigateToPage(context, 1),
                ),
                _buildQuickActionCard(
                  context,
                  'Start Meditation',
                  Icons.self_improvement,
                  Colors.green[100]!,
                      () => _navigateToPage(context, 2),
                ),
                _buildQuickActionCard(
                  context,
                  'Write Diary',
                  Icons.book,
                  Colors.orange[100]!,
                      () => _navigateToPage(context, 3),
                ),
                _buildQuickActionCard(
                  context,
                  'View Statistics',
                  Icons.bar_chart,
                  Colors.purple[100]!,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsScreen(),
                    ),
                  ),
                ),
                _buildQuickActionCard(
                  context,
                  'Mind Assistant',
                  Icons.chat,
                  Colors.pink[100]!,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  ),
                ),
                _buildQuickActionCard(
                  context,
                  'Game',
                  Icons.games,
                  Colors.amber[100]!,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Game2048Screen(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSummary(BuildContext context, List<JournalEntry> entries) {
    // Retrieve only survey-type records
    final surveyEntries = entries
        .where((entry) => entry.type == JournalEntry.TYPE_MOOD_SURVEY)
        .toList();

    if (surveyEntries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No mood records yet'),
          ),
        ),
      );
    }

    // Calculate total count and average score
    final totalCount = surveyEntries.length;
    final averageScore = surveyEntries
        .map((e) => double.parse(e.mood))
        .reduce((a, b) => a + b) / totalCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  '$totalCount times',
                  'Total Records',
                ),
                _buildSummaryItem(
                  '${averageScore.toStringAsFixed(1)} points',
                  'Average Mood',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEntries(BuildContext context, List<JournalEntry> entries) {
    // Retrieve only survey-type records
    final surveyEntries = entries
        .where((entry) => entry.type == JournalEntry.TYPE_MOOD_SURVEY)
        .take(5) // Show only the latest 5 records
        .toList();

    if (surveyEntries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No mood records yet'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...surveyEntries.map((entry) => _buildEntryItem(entry)),
          ],
        ),
      ),
    );
  }
}
