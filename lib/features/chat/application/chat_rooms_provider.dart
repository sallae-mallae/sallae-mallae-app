import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/chat_room.dart';

/// Holds the list of the user's chat rooms shown in the drawer.
///
/// The chat API (GET chat room list) is not available yet, so this starts
/// empty; [refresh] is the single place to wire the network call once the API
/// lands, after which the drawer list populates automatically.
final chatRoomsProvider = NotifierProvider<ChatRoomsNotifier, List<ChatRoom>>(
  ChatRoomsNotifier.new,
);

class ChatRoomsNotifier extends Notifier<List<ChatRoom>> {
  @override
  List<ChatRoom> build() => const <ChatRoom>[];

  /// Reloads the chat room list from the server.
  // TODO: call GET chat room list once the chat API is available.
  Future<void> refresh() async {}
}
