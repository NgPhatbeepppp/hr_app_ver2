// lib/screens/employee/leave_request_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart'; // Thêm animate_do

class LeaveRequestScreen extends StatefulWidget {
  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController _reasonController = TextEditingController();
  bool isSubmitting = false;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (startDate == null || endDate == null || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ngày kết thúc phải sau ngày bắt đầu")),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      String userId = _auth.currentUser!.uid;
      var userDoc = await _firestore.collection('employees').doc(userId).get();
      String userName = userDoc['name'] ?? "Không xác định";

      await _firestore.collection('leave_requests').add({
        "userId": userId,
        "name": userName,
        "startDate": Timestamp.fromDate(startDate!),
        "endDate": Timestamp.fromDate(endDate!),
        "reason": _reasonController.text,
        "status": "Pending",
        "submittedAt": FieldValue.serverTimestamp(),
        "response": null,
        "respondedAt": null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã gửi đơn nghỉ phép thành công")),
      );

      setState(() {
        startDate = null;
        endDate = null;
        _reasonController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
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
            Colors.lightBlue.shade200, // Xanh dương nhạt
            Colors.lightBlue.shade400,
          ],
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top, // Full height minus top padding
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    FadeInDown(
                      duration: Duration(milliseconds: 800),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Gửi Đơn Nghỉ Phép",
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
                    SizedBox(height: 20),
                    // Tiêu đề phụ
                    FadeInUp(
                      duration: Duration(milliseconds: 1000),
                      child: Text(
                        "Điền thông tin nghỉ phép",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Ngày bắt đầu
                    FadeInUp(
                      duration: Duration(milliseconds: 1100),
                      child: GestureDetector(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
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
                              Icon(Icons.calendar_today, color: Colors.lightBlue.shade700),
                              SizedBox(width: 10),
                              Text(
                                startDate == null
                                    ? "Chọn ngày bắt đầu"
                                    : DateFormat('dd/MM/yyyy').format(startDate!),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Ngày kết thúc
                    FadeInUp(
                      duration: Duration(milliseconds: 1200),
                      child: GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
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
                              Icon(Icons.calendar_today, color: Colors.lightBlue.shade700),
                              SizedBox(width: 10),
                              Text(
                                endDate == null
                                    ? "Chọn ngày kết thúc"
                                    : DateFormat('dd/MM/yyyy').format(endDate!),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Lý do nghỉ phép
                    FadeInUp(
                      duration: Duration(milliseconds: 1300),
                      child: TextField(
                        controller: _reasonController,
                        style: GoogleFonts.poppins(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: "Lý do nghỉ phép",
                          labelStyle: GoogleFonts.poppins(color: Colors.black54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.95),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                        maxLines: 3,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Nút gửi
                    FadeInUp(
                      duration: Duration(milliseconds: 1400),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _submitLeaveRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue.shade700,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                          ),
                          child: isSubmitting
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Gửi Đơn",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  }
}
