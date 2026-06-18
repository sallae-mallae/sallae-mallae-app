import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sallae_mallae_app/core/network/dio_provider.dart';

import '../../auth/application/auth_provider.dart';
import '../data/datasources/chat_remote_datasource.dart';
import '../domain/entities/chat_room.dart';

final chatRemoteDatasourceProvider = Provider<ChatRemoteDatasource>((ref) {
  return ChatRemoteDatasource(ref.read(dioProvider));
});

/// Holds the list of the user's chat rooms shown in the drawer, loaded from
/// `GET /api/v1/chat/sessions`. Only authenticated users have a server list, so
/// guests see an empty list.
final chatRoomsProvider = NotifierProvider<ChatRoomsNotifier, List<ChatRoom>>(
  ChatRoomsNotifier.new,
);

class ChatRoomsNotifier extends Notifier<List<ChatRoom>> {
  ChatRemoteDatasource get _datasource =>
      ref.read(chatRemoteDatasourceProvider);

  @override
  List<ChatRoom> build() {
    final session = ref.watch(authProvider).asData?.value;
    if (session?.isAuthenticated ?? false) {
      final userId = session!.userId;
      // Defer so we never mutate state synchronously during build.
      Future.microtask(() => _load(userId));
    }
    return const <ChatRoom>[];
  }

  Future<void> refresh() async {
    final session = ref.read(authProvider).asData?.value;
    if (session?.isAuthenticated ?? false) {
      await _load(session!.userId);
    } else {
      state = const <ChatRoom>[];
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
