class Conversation {
  final int id;
  final int user1Id;
  final int user2Id;
  final String lastMessage;
  final DateTime lastUpdated;

  Conversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.lastMessage,
    required this.lastUpdated,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      user1Id: json['user1Id'],
      user2Id: json['user2Id'],
      lastMessage: json['lastMessage'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'],
    );
  }
}
