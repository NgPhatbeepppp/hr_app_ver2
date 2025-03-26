import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Lịch sử chấm công"),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('employees')
            .doc(userId)
            .collection('attendance')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Không có dữ liệu chấm công."));
          }

          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => Divider(thickness: 1),
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index];
              DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
              String status = data['status'];
              double latitude = data['latitude'];
              double longitude = data['longitude'];

              IconData icon = status == "Check-in" ? Icons.login : Icons.logout;
              Color iconColor = status == "Check-in" ? Colors.green : Colors.red;

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(icon, color: iconColor, size: 30),
                  title: Text(
                    "Ngày: ${DateFormat('dd/MM/yyyy').format(timestamp)}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Thời gian: ${DateFormat('HH:mm').format(timestamp)}"),
                      Text("Trạng thái: $status"),
                      Text("Vị trí: ($latitude, $longitude)"),
                    ],
                  ),
                  trailing: Icon(Icons.location_on, color: Colors.blue),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
