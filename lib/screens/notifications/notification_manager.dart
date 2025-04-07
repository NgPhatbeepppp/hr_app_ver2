// lib/services/notification_manager.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hr_app_ver2/services/notification_service.dart';

class NotificationManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Gửi thông báo đến admin
  Future<void> sendNotificationToAdmin({
    required String adminId,
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      // Lưu thông báo vào Firestore
      await _firestore.collection('notifications').add({
        'userId': adminId,
        'title': title,
        'body': body,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Hiển thị thông báo cục bộ
      await NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID duy nhất
        title: title,
        body: body,
      );
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  // Đánh dấu thông báo là đã đọc
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }
}