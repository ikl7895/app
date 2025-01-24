import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/journal_entry.dart';

class JournalProvider with ChangeNotifier {
  final List<JournalEntry> _entries = [];
  static const String _storageKey = 'journal_entries'; // Key for saving entries in SharedPreferences.
  SharedPreferences? _prefs;

  // Getter for journal entries, returning an unmodifiable list to ensure immutability.
  List<JournalEntry> get entries => List.unmodifiable(_entries);

  // Get all diary entries (type: TYPE_DIARY).
  List<JournalEntry> get diaryEntries {
    final entries = _entries.where((entry) => entry.type == JournalEntry.TYPE_DIARY).toList();
    print('Diary entries count: ${entries.length}');
    return entries;
  }

  // Get all survey entries (type: TYPE_MOOD_SURVEY).
  List<JournalEntry> get surveyEntries {
    final entries = _entries.where((entry) => entry.type == JournalEntry.TYPE_MOOD_SURVEY).toList();
    print('Survey entries count: ${entries.length}');
    return entries;
  }

  // Initialize the provider by loading stored entries from SharedPreferences.
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadEntries();
    } catch (e) {
      print('Error initializing journal provider: $e');
      _entries.clear();
      notifyListeners();
    }
  }

  // Load entries from SharedPreferences.
  Future<void> _loadEntries() async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }

      final String? entriesJson = _prefs?.getString(_storageKey);
      if (entriesJson != null && entriesJson.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(entriesJson);
        _entries.clear();
        _entries.addAll(
          decodedList.map((item) {
            final entry = JournalEntry.fromMap(item);
            print('Loaded entry - type: ${entry.type}, title: ${entry.title}');
            return entry;
          }).toList(),
        );
        _entries.sort((a, b) => b.date.compareTo(a.date));
      }
      notifyListeners();
    } catch (e) {
      print('Error loading entries: $e');
    }
  }

  // Save entries to SharedPreferences.
  Future<void> _saveEntries() async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }

      final String encodedList = json.encode(
        _entries.map((entry) => entry.toMap()).toList(),
      );
      await _prefs?.setString(_storageKey, encodedList);
    } catch (e) {
      print('Error saving entries: $e');
      notifyListeners();
    }
  }

  // Add a new journal entry.
  Future<void> addEntry(JournalEntry entry) async {
    print('Adding entry - type: ${entry.type}, title: ${entry.title}');
    _entries.add(entry);
    _entries.sort((a, b) => b.date.compareTo(a.date));
    await _saveEntries();
    notifyListeners();
  }

  // Delete a journal entry by its ID.
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    await _saveEntries();
    notifyListeners();
  }

  // Update an existing journal entry.
  Future<void> updateEntry(JournalEntry updatedEntry) async {
    final index = _entries.indexWhere((entry) => entry.id == updatedEntry.id);
    if (index != -1) {
      _entries[index] = updatedEntry;
      _entries.sort((a, b) => b.date.compareTo(a.date));
      await _saveEntries();
      notifyListeners();
    }
  }

  // Clear all journal entries.
  Future<void> clearAllEntries() async {
    _entries.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }
}
