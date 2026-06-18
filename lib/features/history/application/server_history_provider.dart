import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sallae_mallae_app/core/network/dio_provider.dart';

import '../data/datasources/history_remote_datasource.dart';
import '../data/models/server_history_item.dart';

final historyRemoteDatasourceProvider = Provider<HistoryRemoteDatasource>((
  ref,
) {
  return HistoryRemoteDatasource(ref.read(dioProvider));
});

final serverHistoryProvider =
    NotifierProvider<ServerHistoryNotifier, ServerHistoryState>(
      ServerHistoryNotifier.new,
    );

class ServerHistoryState {
  const ServerHistoryState({
    required this.items,
    required this.total,
    required this.verdict,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasError,
  });

  const ServerHistoryState.initial()
    : items = const [],
      total = 0,
      verdict = null,
      isLoading = true,
      isLoadingMore = false,
      hasError = false;

  final List<ServerHistoryItem> items;
  final int total;
  final String? verdict;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasError;

  bool get hasMore => items.length < total;

  ServerHistoryState copyWith({
    List<ServerHistoryItem>? items,
    int? total,
    String? verdict,
    bool clearVerdict = false,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasError,
  }) {
    return ServerHistoryState(
      items: items ?? this.items,
      total: total ?? this.total,
      verdict: clearVerdict ? null : verdict ?? this.verdict,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasError: hasError ?? this.hasError,
    );
  }
}

class ServerHistoryNotifier extends Notifier<ServerHistoryState> {
  static const _limit = 20;

  HistoryRemoteDatasource get _datasource =>
      ref.read(historyRemoteDatasourceProvider);

  @override
  ServerHistoryState build() {
    // Defer the first load until after build() returns; reading `state` inside
    // _load before the provider is initialized throws an uninitialized-provider
    // error.
    Future.microtask(() => _load(reset: true));
    return const ServerHistoryState.initial();
  }

  Future<void> setVerdict(String? verdict) async {
    state = state.copyWith(verdict: verdict, clearVerdict: verdict == null);
    await _load(reset: true);
  }

  Future<void> refresh() => _load(reset: true);

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }
    await _load(reset: false);
  }

  Future<void> delete(int id) async {
    await _datasource.delete(id);
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
      total: state.total > 0 ? state.total - 1 : 0,
    );
  }

  Future<void> _load({required bool reset}) async {
    state = reset
        ? state.copyWith(isLoading: true, hasError: false)
        : state.copyWith(isLoadingMore: true, hasError: false);

    try {
      final skip = reset ? 0 : state.items.length;
      final page = await _datasource.list(
        skip: skip,
        limit: _limit,
        verdict: state.verdict,
      );

      state = state.copyWith(
        items: reset ? page.items : [...state.items, ...page.items],
        total: page.total,
        isLoading: false,
        isLoadingMore: false,
        hasError: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        hasError: true,
      );
    }
  }
}
