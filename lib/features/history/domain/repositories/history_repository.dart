import '../entities/history_item.dart';

/// Contract for reading and writing analysis history.
///
/// The local implementation backs the pre-login experience. A server-backed
/// implementation can later fulfil the same contract (and extend it with sync)
/// once authentication is wired up.
abstract interface class HistoryRepository {
  /// Returns saved items ordered from newest to oldest.
  Future<List<HistoryItem>> loadAll();

  Future<void> add(HistoryItem item);

  Future<void> delete(String id);

  Future<void> clear();
}
