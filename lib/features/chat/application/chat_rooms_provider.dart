import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sallae_mallae_app/core/network/dio_provider.dart';

import '../../auth/application/auth_provider.dart';
import '../data/datasources/chat_remote_datasource.dart';
import '../domain/entities/chat_room.dart';

final chatRemoteDatasourceProvider = Provider<ChatRemoteDatasource>((ref) {
  return ChatRemoteDatasource(ref.read(dioProvider));
});

/// Holds the list of chat rooms shown in the drawer, loaded from
/// `GET /api/v1/chat/sessions`. The list is filtered by `user_id` when the user
/// is signed in; otherwise all sessions are returned.
final chatRoomsProvider = NotifierProvider<ChatRoomsNotifier, List<ChatRoom>>(
  ChatRoomsNotifier.new,
);

class ChatRoomsNotifier extends Notifier<List<ChatRoom>> {
  ChatRemoteDatasource get _datasource =>
      ref.read(chatRemoteDatasourceProvider);

  @override
  List<ChatRoom> build() {
    // Reload when sign-in state changes so the filter follows the user.
    final userId = ref.watch(authProvider).asData?.value.userId;
    // Defer so we never mutate state synchronously during build.
    Future.microtask(() => _load(userId));
    return const <ChatRoom>[];
  }

  Future<void> refresh() {
    return _load(ref.read(authProvider).asData?.value.userId);
  }

  /// Deletes a chat room: removes it from the list immediately, then calls the
  /// server. Reloads to restore the item if the request fails.
  Future<void> delete(int id) async {
    state = state.where((room) => room.id != id).toList(growable: false);
    try {
      await _datasource.deleteSession(id);
    } catch (_) {
      await refresh();
    }
  }

  Future<void> _load(int? userId) async {
    try {
      final list = await _datasource.listSessions(userId: userId);
      state = list.items
          .map(
            (s) => ChatRoom(
              id: s.id,
              title: s.title.trim().isEmpty ? '대화 ${s.id}' : s.title.trim(),
              createdAt: s.createdAt ?? DateTime.now(),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      // Keep whatever list we had on a transient failure.
    }
  }
}
