import 'dart:convert';
import 'package:job_portal_app/core/api/api_client.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/models/notification_model.dart';

class NotificationApi {
  static const String base = '/notifications';

  // GET paginated
  static Future<Pagination<AppNotification>> getNotifications({
    int page = 0,
    int size = 10,
  }) async {
    final res = await ApiClient.get(
      '$base?page=$page&size=$size',
      auth: true,
    );

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return Pagination.fromJson(
        json,
        (e) => AppNotification.fromJson(e),
      );
    }

    throw Exception('Failed to load notifications');
  }

  // GET unread count
  static Future<int> getUnreadCount() async {
    final res = await ApiClient.get(
      '$base/unread-count',
      auth: true,
    );

    if (res.statusCode == 200) {
      return int.parse(res.body);
    }

    throw Exception('Failed to load unread count');
  }

  // PUT mark read
  static Future<void> markAsRead(int id) async {
    final res = await ApiClient.put(
      '$base/$id/read',
      auth: true,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to mark as read');
    }
  }

  // PUT mark all
  static Future<void> markAllAsRead() async {
    final res = await ApiClient.put(
      '$base/read-all',
      auth: true,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to mark all as read');
    }
  }

  // DELETE
  static Future<void> deleteNotification(int id) async {
    final res = await ApiClient.delete(
      '$base/$id',
      auth: true,
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete notification');
    }
  }
}