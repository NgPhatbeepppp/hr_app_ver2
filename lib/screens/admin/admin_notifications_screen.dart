// lib/screens/admin/admin_notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr_app_ver2/screens/notifications/notification_manager.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminNotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String adminId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: adminId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}", style: GoogleFonts.poppins()));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Chưa có thông báo",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
            );
          }

          var notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              String notificationId = notification.id;
              String title = notification['title'];
              String body = notification['body'];
              bool isRead = notification['isRead'];
              Timestamp? createdAt = notification['createdAt'];

              return Card(
                color: isRead ? Colors.white : Colors.blue[50],
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: isRead ? Colors.black87 : Colors.blueAccent,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(body, style: GoogleFonts.poppins()),
                      if (createdAt != null)
                        Text(
                          "Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt.toDate())}",
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                  onTap: () async {
                    if (!isRead) {
                      await NotificationManager().markAsRead(notificationId);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}