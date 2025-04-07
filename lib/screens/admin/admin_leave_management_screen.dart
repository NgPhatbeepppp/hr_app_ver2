// lib/screens/admin/admin_leave_management_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr_app_ver2/screens/notifications/notification_manager.dart';
import 'package:intl/intl.dart';

class AdminLeaveManagementScreen extends StatefulWidget {
  @override
  _AdminLeaveManagementScreenState createState() => _AdminLeaveManagementScreenState();
}

class _AdminLeaveManagementScreenState extends State<AdminLeaveManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _respondToRequest(String requestId, String status, String response, String employeeName) async {
    await _firestore.collection('leave_requests').doc(requestId).update({
      "status": status,
      "response": response,
      "respondedAt": FieldValue.serverTimestamp(),
    });

    // Gửi thông báo cho admin
    String adminId = FirebaseFirestore.instance.collection('admins').doc().id; // Thay bằng ID admin thực tế
    await NotificationManager().sendNotificationToAdmin(
      adminId: adminId,
      title: "Đơn nghỉ phép đã được phản hồi",
      body: "Đơn nghỉ phép của $employeeName đã được ${status == 'Approved' ? 'phê duyệt' : 'từ chối'}.",
      type: "leave_response",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã phản hồi đơn nghỉ phép", style: GoogleFonts.poppins())),
    );
  }

  void _showResponseDialog(String requestId, String currentStatus, String employeeName) {
    final TextEditingController _responseController = TextEditingController();
    String newStatus = currentStatus == "Pending" ? "Approved" : currentStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Phản hồi đơn nghỉ phép", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: newStatus,
              items: [
                DropdownMenuItem(value: "Approved", child: Text("Phê duyệt", style: GoogleFonts.poppins())),
                DropdownMenuItem(value: "Rejected", child: Text("Từ chối", style: GoogleFonts.poppins())),
              ],
              onChanged: (value) {
                setState(() {
                  newStatus = value!;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _responseController,
              decoration: InputDecoration(
                labelText: "Lý do phản hồi",
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Hủy", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_responseController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Vui lòng nhập lý do phản hồi", style: GoogleFonts.poppins())),
                );
                return;
              }
              _respondToRequest(requestId, newStatus, _responseController.text, employeeName);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Gửi", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_home.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('leave_requests')
                .orderBy('submittedAt', descending: true)
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
                    "Chưa có đơn nghỉ phép",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              var requests = snapshot.data!.docs;

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  var request = requests[index];
                  String requestId = request.id;
                  String name = request['name'];
                  Timestamp startDate = request['startDate'];
                  Timestamp endDate = request['endDate'];
                  String reason = request['reason'];
                  String status = request['status'];
                  Timestamp? submittedAt = request['submittedAt'];
                  String response = request['response'] ?? "Chưa có phản hồi";
                  Timestamp? respondedAt = request['respondedAt'];

                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(
                        "Nhân viên: $name",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Từ: ${DateFormat('dd/MM/yyyy').format(startDate.toDate())} - Đến: ${DateFormat('dd/MM/yyyy').format(endDate.toDate())}",
                            style: GoogleFonts.poppins(),
                          ),
                          Text("Lý do: $reason", style: GoogleFonts.poppins()),
                          Text("Trạng thái: $status", style: GoogleFonts.poppins()),
                          Text(
                            "Gửi lúc: ${submittedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(submittedAt.toDate()) : 'Chưa xác định'}",
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                          Text("Phản hồi: $response", style: GoogleFonts.poppins(color: Colors.grey)),
                          if (respondedAt != null)
                            Text(
                              "Phản hồi lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(respondedAt.toDate())}",
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                        ],
                      ),
                      trailing: status == "Pending"
                          ? IconButton(
                              icon: Icon(Icons.reply, color: Colors.blueAccent),
                              onPressed: () => _showResponseDialog(requestId, status, name),
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}