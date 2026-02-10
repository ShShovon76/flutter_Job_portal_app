class ChatItem {
  final String name;
  final String lastMessage;
  final String time;
  final bool unread;
  final bool isEmployer;

  ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.isEmployer,
  });
}
