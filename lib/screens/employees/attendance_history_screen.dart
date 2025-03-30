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
            .collection('attendance')
            .where('userId', isEqualTo: userId)
            .orderBy('checkInTime', descending: true)
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

              DateTime checkInTime = (data['checkInTime'] as Timestamp).toDate();
              DateTime? checkOutTime = data['checkOutTime'] != null
                  ? (data['checkOutTime'] as Timestamp).toDate()
                  : null;

              // Lấy dữ liệu vị trí từ Map
              Map<String, dynamic>? location = data['location'] as Map<String, dynamic>?;
              double latitude = location?['latitude'] ?? 0.0;
              double longitude = location?['longitude'] ?? 0.0;

              String workDuration = checkOutTime != null
                  ? _calculateDuration(checkInTime, checkOutTime)
                  : "Đang làm việc";

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.access_time, color: Colors.blue, size: 30),
                  title: Text(
                    "Ngày: ${DateFormat('dd/MM/yyyy').format(checkInTime)}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Check-in: ${DateFormat('HH:mm').format(checkInTime)}"),
                      Text(
                        checkOutTime != null
                            ? "Check-out: ${DateFormat('HH:mm').format(checkOutTime)}"
                            : "Chưa Check-out",
                        style: TextStyle(color: checkOutTime != null ? Colors.black : Colors.red),
                      ),
                      Text("Thời gian làm việc: $workDuration"),
                      Text("Vị trí: ($latitude, $longitude)"),
                    ],
                  ),
                  trailing: Icon(Icons.location_on, color: Colors.redAccent),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _calculateDuration(DateTime checkIn, DateTime checkOut) {
    Duration diff = checkOut.difference(checkIn);
    int hours = diff.inHours;
    int minutes = (diff.inMinutes % 60);
    return "${hours}h ${minutes}m";
  }
}
