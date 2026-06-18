/// A saved chat room: one analysis conversation (the user's question plus the
/// AI verdict thread) created on the server when an analysis is requested.
class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  final int id;

  /// Short title shown in the drawer list (e.g. the first question).
  final String title;

  final DateTime createdAt;
}
