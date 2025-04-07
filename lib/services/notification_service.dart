// lib/services/notification_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) {
      // Không khởi tạo trên web vì flutter_local_notifications không hỗ trợ
      print("Notifications are not supported on web.");
      return;
    }

    // Khởi tạo cho mobile (Android/iOS)
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification({required int id, required String title, required String body}) async {
    if (kIsWeb) {
      // Có thể thay thế bằng thông báo web (ví dụ: JavaScript Notification API) nếu cần
      print("Web Notification: $title - $body");
      return;
    }

    // Hiển thị thông báo trên mobile
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hr_app_channel',
      'HR App Notifications',
      channelDescription: 'Notifications for HR App',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(id, title, body, notificationDetails);
  }
}