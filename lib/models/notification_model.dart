// ignore_for_file: constant_identifier_names

enum NotificationType {
  APPLICATION_UPDATE,
  NEW_JOB_POST,
  PROFILE_VIEWED,
  SYSTEM_ALERT,
  OTHER,
}

extension NotificationTypeX on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.APPLICATION_UPDATE:
        return "Application Update";
      case NotificationType.NEW_JOB_POST:
        return "New Job Posted";
      case NotificationType.PROFILE_VIEWED:
        return "Profile Viewed";
      case NotificationType.SYSTEM_ALERT:
        return "System Alert";
      default:
        return "Notification";
    }
  }
}

NotificationType notificationTypeFromString(String value) {
  return NotificationType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => NotificationType.OTHER,
  );
}

String notificationTypeToString(NotificationType type) {
  return type.name;
}
class AppNotification {
  final int id;
  final int userId;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.actionUrl,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      message: json['message'],
      type: notificationTypeFromString(json['type']),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      actionUrl: json['actionUrl'],
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl,
    );
  }
}