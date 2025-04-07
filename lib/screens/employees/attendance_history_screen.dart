// lib/screens/attendance_history_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String? selectedMonth;
  List<String> availableMonths = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableMonths();
  }

  Future<void> _loadAvailableMonths() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .orderBy('checkInTime', descending: true)
        .get();

    final months = snapshot.docs.map((doc) {
      DateTime checkInTime = (doc['checkInTime'] as Timestamp).toDate();
      return "${checkInTime.year}-${checkInTime.month.toString().padLeft(2, '0')}";
    }).toSet().toList();

    months.sort((a, b) => b.compareTo(a));

    setState(() {
      availableMonths = months;
      selectedMonth = months.isNotEmpty ? months.first : null;
    });
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
                        "Lịch sử chấm công",
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
              // Dropdown chọn tháng
              FadeInUp(
                duration: Duration(milliseconds: 1000),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: DropdownButtonFormField<String>(
                    value: selectedMonth,
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
                      "Chọn tháng",
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                    items: availableMonths.map((month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(
                          month,
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value;
                      });
                    },
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                  ),
                ),
              ),
              // Danh sách chấm công
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('attendance')
                      .where('userId', isEqualTo: userId)
                      .orderBy('checkInTime', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: FadeInUp(
                          duration: Duration(milliseconds: 1200),
                          child: Text(
                            "Không có dữ liệu chấm công.",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      );
                    }

                    // Lọc theo tháng đã chọn
                    var filteredDocs = snapshot.data!.docs.where((doc) {
                      DateTime checkInTime = (doc['checkInTime'] as Timestamp).toDate();
                      String docMonth =
                          "${checkInTime.year}-${checkInTime.month.toString().padLeft(2, '0')}";
                      return selectedMonth == null || docMonth == selectedMonth;
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return Center(
                        child: FadeInUp(
                          duration: Duration(milliseconds: 1200),
                          child: Text(
                            "Không có dữ liệu chấm công cho tháng này.",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredDocs.length,
                      separatorBuilder: (context, index) => SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        var data = filteredDocs[index];

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

                        // Xác định trạng thái để thay đổi màu sắc
                        bool isWorking = checkOutTime == null;
                        Color statusColor = isWorking ? Colors.orange : Colors.green;

                        return FadeInUp(
                          duration: Duration(milliseconds: 800 + (index * 100)),
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: Colors.white.withOpacity(0.95),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor.withOpacity(0.1),
                                child: Icon(
                                  Icons.access_time,
                                  color: statusColor,
                                  size: 24,
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Ngày: ${DateFormat('dd/MM/yyyy').format(checkInTime)}",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isWorking ? "Đang làm việc" : "Đã hoàn thành",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.login, color: Colors.black54, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        "Check-in: ${DateFormat('HH:mm').format(checkInTime)}",
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
                                      Icon(Icons.logout, color: Colors.black54, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        checkOutTime != null
                                            ? "Check-out: ${DateFormat('HH:mm').format(checkOutTime)}"
                                            : "Chưa Check-out",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: checkOutTime != null ? Colors.black54 : Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.timer, color: Colors.black54, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        "Thời gian: $workDuration",
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
                                      Icon(Icons.location_on, color: Colors.black54, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        "Vị trí: ($latitude, $longitude)",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
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

  String _calculateDuration(DateTime checkIn, DateTime checkOut) {
    Duration diff = checkOut.difference(checkIn);
    int hours = diff.inHours;
    int minutes = (diff.inMinutes % 60);
    return "${hours}h ${minutes}m";
  }
}