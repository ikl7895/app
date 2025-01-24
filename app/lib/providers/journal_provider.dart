import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/journal_entry.dart';
import '../services/firebase_service.dart';

class JournalProvider with ChangeNotifier {
  final List<JournalEntry> _entries = [];
  static const String _storageKey = 'journal_entries'; // Key for saving entries in SharedPreferences.
  SharedPreferences? _prefs;
  final FirebaseService _firebaseService = FirebaseService();
  String? _userId; // Current user ID

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

  // Set the user ID and start syncing
  Future<void> setUserId(String userId) async {
    _userId = userId;
    await _syncWithFirebase();
    // Listen to Firebase updates
    _firebaseService.getJournalEntries(userId).listen((entries) {
      _handleFirebaseUpdate(entries);
    });
  }

  // Handle updates from Firebase
  void _handleFirebaseUpdate(List<JournalEntry> firebaseEntries) {
    // Merge local and remote data
    final Map<String, JournalEntry> entriesMap = {};

    // Add local data first
    for (var entry in _entries) {
      entriesMap[entry.id] = entry;
    }

    // Add remote data (remote data overrides conflicts)
    for (var entry in firebaseEntries) {
      entriesMap[entry.id] = entry;
    }

    _entries.clear();
    _entries.addAll(entriesMap.values);
    _entries.sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
    _saveEntries(); // Save to local storage
  }

  // Sync with Firebase
  Future<void> _syncWithFirebase() async {
    if (_userId == null) return;

    try {
      await _firebaseService.syncLocalToFirebase(_userId!, _entries);
    } catch (e) {
      print('Firebase sync error: $e');
    }
  }

  // Override the add method
  @override
  Future<void> addEntry(JournalEntry entry) async {
    _entries.add(entry);
    _entries.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();

    await _saveEntries();
    if (_userId != null) {
      await _firebaseService.saveJournalEntry(_userId!, entry);
    }
  }

  // Override the delete method
  @override
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();

    await _saveEntries();
    if (_userId != null) {
      await _firebaseService.deleteJournalEntry(_userId!, id);
    }
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
