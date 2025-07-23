import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationItem> _notifications = [];
  final ValueNotifier<List<NotificationItem>> notificationsNotifier = 
      ValueNotifier<List<NotificationItem>>([]);

  List<NotificationItem> get notifications => _notifications;

  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? candidateName,
  }) {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      candidateName: candidateName,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _notifications.insert(0, notification);
    notificationsNotifier.value = List.from(_notifications);
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notificationsNotifier.value = List.from(_notifications);
    }
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notificationsNotifier.value = List.from(_notifications);
  }

  void clearAll() {
    _notifications.clear();
    notificationsNotifier.value = [];
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String? candidateName;
  final DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.candidateName,
    required this.timestamp,
    this.isRead = false,
  });
}

enum NotificationType {
  interview,
  reschedule,
  reached,
  general,
}
