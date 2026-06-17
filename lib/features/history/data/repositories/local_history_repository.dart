import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repository.dart';

/// Stores analysis history locally as a JSON list in [SharedPreferences].
///
/// This works before login so the user keeps their history without an account.
class LocalHistoryRepository implements HistoryRepository {
  const LocalHistoryRepository();

  static const _storageKey = 'local_history_items';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<List<HistoryItem>> loadAll() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_storageKey) ?? const [];

    final items = <HistoryItem>[];
    for (final entry in raw) {
      try {
        final json = jsonDecode(entry) as Map<String, dynamic>;
        items.add(HistoryItem.fromJson(json));
      } catch (_) {
        // Skip malformed entries rather than failing the whole load.
      }
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<void> add(HistoryItem item) async {
    final prefs = await _prefs;
    final raw = List<String>.from(prefs.getStringList(_storageKey) ?? const []);
    raw.add(jsonEncode(item.toJson()));
    await prefs.setStringList(_storageKey, raw);
  }

  @override
  Future<void> delete(String id) async {
    final prefs = await _prefs;
    final items = await loadAll();
    final remaining = items
        .where((item) => item.id != id)
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, remaining);
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_storageKey);
  }
}
