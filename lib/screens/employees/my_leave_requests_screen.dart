// lib/screens/employee/my_leave_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class MyLeaveRequestsScreen extends StatefulWidget {
  @override
  _MyLeaveRequestsScreenState createState() => _MyLeaveRequestsScreenState();
}

class _MyLeaveRequestsScreenState extends State<MyLeaveRequestsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<QueryDocumentSnapshot> _leaveRequests = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedStatus = "Tất cả"; // Thêm bộ lọc trạng thái

  @override
  void initState() {
    super.initState();
    fetchLeaveRequests();
  }

  Future<void> fetchLeaveRequests() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final query = await _firestore
          .collection('leave_requests')
          .where('userId', isEqualTo: user.uid)
          .orderBy('submittedAt', descending: true)
          .get();

      setState(() {
        _leaveRequests = query.docs;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      print("Error fetching leave requests: $e");
      String message = "Lỗi khi tải danh sách đơn nghỉ phép";
      if (e.toString().contains("The query requires an index")) {
        message = "Truy vấn yêu cầu chỉ mục. Vui lòng tạo chỉ mục trong Firestore.";
      }

      setState(() {
        isLoading = false;
        errorMessage = message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case "Approved":
        color = Colors.green;
        break;
      case "Rejected":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showLeaveRequestDetails(QueryDocumentSnapshot doc) {
    final String requestId = doc.id;
    final Timestamp startDate = doc['startDate'];
    final Timestamp endDate = doc['endDate'];
    final String reason = doc['reason'];
    final String status = doc['status'];
    final Timestamp? submittedAt = doc['submittedAt'];
    final String response = doc['response'] ?? "Chưa có phản hồi";
    final Timestamp? respondedAt = doc['respondedAt'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "Chi tiết đơn nghỉ phép",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blueAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Ngày nghỉ: ${DateFormat('dd/MM/yyyy').format(startDate.toDate())} → ${DateFormat('dd/MM/yyyy').format(endDate.toDate())}",
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.description, color: Colors.blueAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Lý do: $reason",
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info, color: Colors.blueAccent, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Trạng thái: $status",
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Gửi lúc: ${submittedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(submittedAt.toDate()) : 'Chưa xác định'}",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.comment, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Phản hồi: $response",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              if (respondedAt != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Phản hồi lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(respondedAt.toDate())}",
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Đóng",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          if (status == "Pending") ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showUpdateLeaveRequestDialog(doc);
              },
              child: Text(
                "Cập nhật",
                style: GoogleFonts.poppins(color: Colors.blueAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteLeaveRequest(requestId);
              },
              child: Text(
                "Xóa",
                style: GoogleFonts.poppins(color: Colors.redAccent),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showUpdateLeaveRequestDialog(QueryDocumentSnapshot doc) {
    final String requestId = doc.id;
    DateTime startDate = (doc['startDate'] as Timestamp).toDate();
    DateTime endDate = (doc['endDate'] as Timestamp).toDate();
    final TextEditingController _reasonController = TextEditingController(text: doc['reason']);
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            "Cập nhật đơn nghỉ phép",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeInUp(
                  duration: Duration(milliseconds: 800),
                  child: GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2026),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            spreadRadius: 2,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blueAccent),
                          SizedBox(width: 10),
                          Text(
                            DateFormat('dd/MM/yyyy').format(startDate),
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                FadeInUp(
                  duration: Duration(milliseconds: 900),
                  child: GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2026),
                      );
                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            spreadRadius: 2,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blueAccent),
                          SizedBox(width: 10),
                          Text(
                            DateFormat('dd/MM/yyyy').format(endDate),
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                FadeInUp(
                  duration: Duration(milliseconds: 1000),
                  child: TextField(
                    controller: _reasonController,
                    style: GoogleFonts.poppins(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: "Lý do nghỉ phép",
                      labelStyle: GoogleFonts.poppins(color: Colors.black54),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Hủy",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (startDate == null || endDate == null || _reasonController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
                        );
                        return;
                      }

                      if (endDate.isBefore(startDate)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Ngày kết thúc phải sau ngày bắt đầu")),
                        );
                        return;
                      }

                      setState(() {
                        isSubmitting = true;
                      });

                      try {
                        await _firestore.collection('leave_requests').doc(requestId).update({
                          "startDate": Timestamp.fromDate(startDate),
                          "endDate": Timestamp.fromDate(endDate),
                          "reason": _reasonController.text,
                          "submittedAt": FieldValue.serverTimestamp(),
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Đã cập nhật đơn nghỉ phép")),
                        );

                        await fetchLeaveRequests();
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Lỗi: $e")),
                        );
                      } finally {
                        setState(() {
                          isSubmitting = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Cập nhật",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteLeaveRequest(String requestId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "Xác nhận xóa",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: Text(
          "Bạn có chắc muốn xóa đơn nghỉ phép này?",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Hủy",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Xóa",
              style: GoogleFonts.poppins(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestore.collection('leave_requests').doc(requestId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xóa đơn nghỉ phép")),
      );
      await fetchLeaveRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueAccent.shade700,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              FadeInDown(
                duration: Duration(milliseconds: 800),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Lịch sử đơn nghỉ phép",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
              // Dropdown lọc trạng thái
              FadeInUp(
                duration: Duration(milliseconds: 1000),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.95),
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    hint: Text(
                      "Lọc trạng thái",
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                    items: ["Tất cả", "Pending", "Approved", "Rejected"].map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(
                          status,
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                  ),
                ),
              ),
              // Danh sách đơn nghỉ phép
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.white))
                    : errorMessage != null
                        ? Center(
                            child: FadeInUp(
                              duration: Duration(milliseconds: 1200),
                              child: Text(
                                errorMessage!,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : _leaveRequests.isEmpty
                            ? Center(
                                child: FadeInUp(
                                  duration: Duration(milliseconds: 1200),
                                  child: Text(
                                    "Bạn chưa gửi đơn nghỉ phép nào",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: _leaveRequests.length,
                                itemBuilder: (context, index) {
                                  final doc = _leaveRequests[index];
                                  final Timestamp startDate = doc['startDate'];
                                  final Timestamp endDate = doc['endDate'];
                                  final String reason = doc['reason'];
                                  final String status = doc['status'];
                                  final Timestamp? submittedAt = doc['submittedAt'];

                                  // Lọc theo trạng thái
                                  if (selectedStatus != "Tất cả" && status != selectedStatus) {
                                    return SizedBox.shrink();
                                  }

                                  return FadeInUp(
                                    duration: Duration(milliseconds: 800 + (index * 100)),
                                    child: Card(
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      color: Colors.white.withOpacity(0.95),
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      child: ListTile(
                                        onTap: () => _showLeaveRequestDetails(doc),
                                        contentPadding: EdgeInsets.all(12),
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.blueAccent.withOpacity(0.1),
                                          child: Icon(
                                            Icons.request_page,
                                            color: Colors.blueAccent,
                                            size: 24,
                                          ),
                                        ),
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${DateFormat('dd/MM/yyyy').format(startDate.toDate())} → ${DateFormat('dd/MM/yyyy').format(endDate.toDate())}",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            _buildStatusChip(status),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.description, color: Colors.black54, size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Lý do: $reason",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.access_time, color: Colors.black54, size: 16),
                                                SizedBox(width: 4),
                                                Text(
                                                  "Gửi lúc: ${submittedAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(submittedAt.toDate()) : 'Chưa xác định'}",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}