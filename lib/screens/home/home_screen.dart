import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hr_app_ver2/screens/employees/attendance_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isCheckedIn = false; // Trạng thái chấm công

  @override
  void initState() {
    super.initState();
    _getAttendanceStatus();
  }

  Future<void> _getAttendanceStatus() async {
    String userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    var snapshot = await _firestore
        .collection('employees')
        .doc(userId)
        .collection('attendance')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        isCheckedIn = snapshot.docs.first['status'] == "Check-in";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Hình nền
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_home.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Nội dung chính
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    "Chào mừng bạn!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.white,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Quản lý tài khoản nhân viên dễ dàng & hiệu quả",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.white,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Hộp trạng thái chấm công
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCheckedIn ? Icons.check_circle : Icons.cancel,
                          color: isCheckedIn ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        SizedBox(width: 10),
                        Text(
                          isCheckedIn ? "Đang chấm công" : "Chưa chấm công",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Lưới chức năng
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3, // 3 cột thay vì 2
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _buildFeatureCard(Icons.person, "Nhân viên"),
                        _buildFeatureCard(Icons.notifications, "Thông báo"),
                        _buildFeatureCard(Icons.calendar_today, "Lịch nghỉ"),
                        _buildFeatureCard(Icons.attach_money, "Bảng lương"),
                        _buildFeatureCard(Icons.access_time, "Chấm công", context), // ✅ Nút chấm công
                        _buildFeatureCard(Icons.insert_chart, "Thống kê"),
                        _buildFeatureCard(Icons.settings, "Cài đặt"),
                        _buildFeatureCard(Icons.support, "Hỗ trợ"),
                        _buildFeatureCard(Icons.info, "Thông tin"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm tạo thẻ chức năng
  Widget _buildFeatureCard(IconData icon, String title, [BuildContext? context]) {
    return GestureDetector(
      onTap: () {
        if (title == "Chấm công" && context != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AttendanceScreen()),
          );
        }
      },
      child: Card(
        color: Colors.white.withOpacity(0.95),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.blueAccent), // Giảm kích thước icon
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14, // Giảm kích thước chữ
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
