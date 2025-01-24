import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';
import '../models/journal_entry.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Statistics'),
      ),
      body: Consumer<JournalProvider>(
        builder: (context, provider, child) {
          // Retrieve only survey-type records
          final surveyEntries = provider.entries
              .where((entry) => entry.type == JournalEntry.TYPE_MOOD_SURVEY)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMoodSummary(surveyEntries),
                const SizedBox(height: 20),
                _buildWeeklyMoodChart(surveyEntries),
                const SizedBox(height: 20),
                _buildRecentRecords(surveyEntries),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoodSummary(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No mood survey records available.'),
          ),
        ),
      );
    }

    final totalCount = entries.length;
    final averageScore = entries
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
                _buildSummaryItem('$totalCount times', 'Number of Records'),
                _buildSummaryItem('${averageScore.toStringAsFixed(1)} points', 'Average Mood'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRecords(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No mood survey records available.'),
          ),
        ),
      );
    }

    final recentEntries = entries.take(5).toList();

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
            ...recentEntries.map((entry) => _buildRecordItem(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(JournalEntry entry) {
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
          Text(
            '${entry.mood} points',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyMoodChart(List<JournalEntry> entries) {
    // Retrieve data for the last 7 days
    final now = DateTime.now();
    final weekEntries = entries.where((entry) {
      final diff = now.difference(entry.date).inDays;
      return diff < 7;
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Mood Trend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final date = now.subtract(Duration(days: 6 - index));
                  final dayEntries = weekEntries.where((entry) {
                    return entry.date.day == date.day &&
                        entry.date.month == date.month;
                  }).toList();

                  double mood;
                  try {
                    mood = dayEntries.isEmpty
                        ? 0.0
                        : dayEntries
                        .map((e) => double.tryParse(e.mood) ?? 0.0)
                        .reduce((a, b) => a + b) /
                        dayEntries.length;
                  } catch (e) {
                    mood = 0.0;
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        mood.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: mood * 20,
                        color: Colors.blue.withOpacity(0.7),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('E').format(date),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
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
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
