import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';

class FirebaseService {
  late final FirebaseFirestore _firestore;

  FirebaseService() {
    _firestore = FirebaseFirestore.instance;
  }

  // Retrieve all journal entries for the user
  Stream<List<JournalEntry>> getJournalEntries(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('entries')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return JournalEntry.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }

  // Add or update a journal entry
  Future<void> saveJournalEntry(String userId, JournalEntry entry) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('entries')
        .doc(entry.id)
        .set(entry.toMap());
  }

  // Delete a journal entry
  Future<void> deleteJournalEntry(String userId, String entryId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('entries')
        .doc(entryId)
        .delete();
  }

  // Sync local data to Firebase
  Future<void> syncLocalToFirebase(String userId, List<JournalEntry> localEntries) async {
    final batch = _firestore.batch();
    final entriesRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('entries');

    for (var entry in localEntries) {
      batch.set(entriesRef.doc(entry.id), entry.toMap());
    }

    await batch.commit();
  }
}
