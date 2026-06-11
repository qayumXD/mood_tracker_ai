import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_model.dart';

class JournalService {
  static const String _journalKey = 'journals';
  late SharedPreferences _prefs;
  List<Journal> _journals = [];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadJournals();
  }

  void _loadJournals() {
    final stored = _prefs.getStringList(_journalKey) ?? [];
    _journals = stored
        .map((j) => Journal.fromJson(jsonDecode(j)))
        .toList();
  }

  Future<void> _saveJournals() async {
    final journalStrings = _journals
        .map((j) => jsonEncode(j.toJson()))
        .toList();
    await _prefs.setStringList(_journalKey, journalStrings);
  }

  Future<List<Journal>> getAllJournals() async {
    await init();
    return _journals;
  }

  Future<Journal?> getJournal(String id) async {
    await init();
    try {
      return _journals.firstWhere((j) => j.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveJournal(Journal journal) async {
    await init();
    _journals.insert(0, journal);
    await _saveJournals();
  }

  Future<void> updateJournal(Journal journal) async {
    await init();
    final index = _journals.indexWhere((j) => j.id == journal.id);
    if (index != -1) {
      _journals[index] = journal;
      await _saveJournals();
    }
  }

  Future<void> deleteJournal(String id) async {
    await init();
    _journals.removeWhere((j) => j.id == id);
    await _saveJournals();
  }

  Future<List<Journal>> searchJournals(String query) async {
    await init();
    return _journals
        .where((j) => j.title.toLowerCase().contains(query.toLowerCase()) ||
                      j.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
