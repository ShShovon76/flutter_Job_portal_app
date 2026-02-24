import 'package:flutter/material.dart';
import 'package:job_portal_app/core/api/notification_api.dart';
import 'package:job_portal_app/models/job_search_filter.dart';
import 'package:job_portal_app/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = [];

  bool _isLoading = false;
  bool _isFetchingMore = false;
  String? _error;

  int _currentPage = 0;
  final int _size = 10;
  int _totalPages = 0;

  int _unreadCount = 0;

  // ---------------- GETTERS ----------------
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;
  String? get error => _error;
  bool get hasMore => _currentPage < _totalPages - 1;
  int get unreadCount => _unreadCount;

  // ---------------- LOAD FIRST PAGE ----------------
  Future<void> loadNotifications() async {
    _setLoading(true);
    _error = null;
    _currentPage = 0;

    try {
      final Pagination<AppNotification> response =
          await NotificationApi.getNotifications(
        page: _currentPage,
        size: _size,
      );

      _notifications
        ..clear()
        ..addAll(response.items);

      _totalPages = response.totalPages;

      await loadUnreadCount();
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  // ---------------- LOAD MORE ----------------
  Future<void> loadMore() async {
    if (!hasMore || _isFetchingMore) return;

    _setFetchingMore(true);

    try {
      _currentPage++;

      final Pagination<AppNotification> response =
          await NotificationApi.getNotifications(
        page: _currentPage,
        size: _size,
      );

      _notifications.addAll(response.items);
      _totalPages = response.totalPages;
    } catch (_) {}

    _setFetchingMore(false);
  }

  // ---------------- UNREAD COUNT ----------------
  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await NotificationApi.getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  // ---------------- MARK READ ----------------
  Future<void> markAsRead(int id) async {
    try {
      await NotificationApi.markAsRead(id);

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] =
            _notifications[index].copyWith(isRead: true);

        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
        notifyListeners();
      }
    } catch (_) {}
  }

  // ---------------- MARK ALL ----------------
  Future<void> markAllAsRead() async {
    try {
      await NotificationApi.markAllAsRead();

      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] =
            _notifications[i].copyWith(isRead: true);
      }

      _unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }

  // ---------------- DELETE ----------------
  Future<void> deleteNotification(int id) async {
    try {
      await NotificationApi.deleteNotification(id);

      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (_) {}
  }

  // ---------------- PRIVATE ----------------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setFetchingMore(bool value) {
    _isFetchingMore = value;
    notifyListeners();
  }
}