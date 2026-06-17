import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/local_history_repository.dart';
import '../domain/entities/history_item.dart';
import '../domain/repositories/history_repository.dart';

/// Backing store for history. Swap this for a server-backed implementation once
/// authentication and sync are available.
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return const LocalHistoryRepository();
});

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<HistoryItem>>(
      HistoryNotifier.new,
    );

class HistoryNotifier extends AsyncNotifier<List<HistoryItem>> {
  HistoryRepository get _repository => ref.read(historyRepositoryProvider);

  @override
  Future<List<HistoryItem>> build() {
    return _repository.loadAll();
  }

  Future<void> add(HistoryItem item) async {
    await _repository.add(item);
    state = AsyncData(await _repository.loadAll());
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    state = AsyncData(await _repository.loadAll());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.loadAll);
  }
}
