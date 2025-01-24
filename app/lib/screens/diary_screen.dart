import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';
import 'dart:math';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary'),
      ),
      body: Consumer<JournalProvider>(
        builder: (context, journalProvider, child) {
          // Retrieve only diary-type entries
          final diaryEntries = journalProvider.entries
              .where((entry) => entry.type == JournalEntry.TYPE_DIARY)
              .toList();

          if (diaryEntries.isEmpty) {
            return const Center(
              child: Text('No diary entries yet. Tap the button below to start writing!'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: diaryEntries.length, // Use filtered list length
            itemBuilder: (context, index) {
              final entry = diaryEntries[index]; // Use filtered list
              return _buildJournalCard(context, entry);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildJournalCard(BuildContext context, JournalEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showEntryDetails(context, entry),
        onLongPress: () => _showDeleteDialog(context, entry),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('yyyy/MM/dd').format(entry.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.mood,
                    color: _getMoodColor(entry.mood),
                  ),
                  const SizedBox(width: 8),
                  Text(entry.mood),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DiaryEntryDialog(),
    );
  }

  void _showEntryDetails(BuildContext context, JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => DiaryEntryDialog(entry: entry),
    );
  }

  void _showDeleteDialog(BuildContext context, JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Diary Entry'),
        content: const Text('Are you sure you want to delete this diary entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<JournalProvider>().deleteEntry(entry.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return Colors.yellow;
      case 'Calm':
        return Colors.blue;
      case 'Sad':
        return Colors.grey;
      case 'Angry':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class DiaryEntryDialog extends StatefulWidget {
  final JournalEntry? entry;

  const DiaryEntryDialog({Key? key, this.entry}) : super(key: key);

  @override
  State<DiaryEntryDialog> createState() => _DiaryEntryDialogState();
}

class _DiaryEntryDialogState extends State<DiaryEntryDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _selectedMood = 'Happy';
  final List<String> _moods = ['Happy', 'Calm', 'Sad', 'Angry'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(text: widget.entry?.content ?? '');
    if (widget.entry != null) {
      _selectedMood = widget.entry!.mood;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the title and content')),
      );
      return;
    }

    final journalProvider = context.read<JournalProvider>();
    final entry = JournalEntry(
      id: widget.entry?.id ?? DateTime.now().toString(),
      title: _titleController.text,
      content: _contentController.text,
      date: widget.entry?.date ?? DateTime.now(),
      mood: _selectedMood,
      type: JournalEntry.TYPE_DIARY,
    );

    if (widget.entry == null) {
      journalProvider.addEntry(entry);
    } else {
      journalProvider.updateEntry(entry);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.entry == null ? 'Add Diary Entry' : 'Edit Diary Entry',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMood,
              decoration: const InputDecoration(
                labelText: 'Mood',
                border: OutlineInputBorder(),
              ),
              items: _moods.map((mood) {
                return DropdownMenuItem(
                  value: mood,
                  child: Text(mood),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMood = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveEntry,
                  child: Text(widget.entry == null ? 'Add' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
