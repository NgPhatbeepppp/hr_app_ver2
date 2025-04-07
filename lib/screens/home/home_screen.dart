import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hr_app_ver2/screens/employees/attendance_screen.dart';
import 'package:hr_app_ver2/screens/employees/employee_salary_screen.dart'; // Đường dẫn đến AttendanceScreen
import 'package:hr_app_ver2/screens/employees/employees_screen.dart';
import 'package:hr_app_ver2/screens/employees/leave_request_screen.dart';
import 'package:hr_app_ver2/screens/employees/my_leave_requests_screen.dart'; // Đường dẫn đến LeaveRequestScreen
import 'package:hr_app_ver2/screens/about_screen.dart';
import 'package:hr_app_ver2/screens/notifications/notifications_screen.dart'; 
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

    try {
      var snapshot = await _firestore
          .collection('attendance') // Đồng bộ với AttendanceScreen
          .where('userId', isEqualTo: userId)
          .orderBy('checkInTime', descending: true) // Sắp xếp theo checkInTime
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var lastAttendance = snapshot.docs.first;
        setState(() {
          // Kiểm tra xem checkOutTime có null không để xác định trạng thái chấm công
          isCheckedIn = lastAttendance['checkOutTime'] == null;
        });
      } else {
        setState(() {
          isCheckedIn = false; // Nếu không có bản ghi nào, coi như chưa chấm công
        });
      }
    } catch (e) {
      // Xử lý lỗi (ví dụ: mất kết nối mạng)
      print("Lỗi khi lấy trạng thái chấm công: $e");
      setState(() {
        isCheckedIn = false; // Mặc định là chưa chấm công nếu có lỗi
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
                  // Tiêu đề với gradient
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Chào mừng bạn!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Quản lý tài khoản nhân viên dễ dàng & hiệu quả",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black45,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Hộp trạng thái chấm công với hiệu ứng động
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isCheckedIn ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 2,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: Icon(
                            isCheckedIn ? Icons.check_circle : Icons.cancel,
                            key: ValueKey<bool>(isCheckedIn),
                            color: isCheckedIn ? Colors.green : Colors.red,
                            size: 32,
                          ),
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
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _buildFeatureCard(Icons.person, "Nhân viên", Colors.blueAccent, context),
                        _buildFeatureCard(Icons.notifications, "Thông báo", Colors.orange, context),
                        _buildFeatureCard(Icons.calendar_today, "Đơn nghỉ", Colors.purple, context),
                        _buildFeatureCard(Icons.attach_money, "Xem lương", Colors.green, context),
                        _buildFeatureCard(Icons.access_time, "Chấm công", Colors.teal, context),
                        _buildFeatureCard(Icons.insert_chart, "Thống kê", Colors.indigo),
                        _buildFeatureCard(Icons.settings, "Cài đặt", Colors.grey),
                        _buildFeatureCard(Icons.list, "Danh sách đơn", Colors.cyan, context),
                        _buildFeatureCard(Icons.info, "Thông tin", Colors.blueGrey, context),
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

  // Hàm tạo thẻ chức năng với màu sắc và hiệu ứng hover
  Widget _buildFeatureCard(IconData icon, String title, Color iconColor, [BuildContext? context]) {
    return GestureDetector(
      onTap: () {
        print("Đã nhấn vào: $title");
        if (title == "Chấm công" && context != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AttendanceScreen()),
          ).then((_) {
            // Cập nhật trạng thái chấm công khi quay lại từ AttendanceScreen
            _getAttendanceStatus();
          });
          } else if (title == "Xem lương" ) {
          Navigator.push(
            context!,
            MaterialPageRoute(builder: (context) => EmployeeSalaryScreen()),
          );
           } else if (title == "Đơn nghỉ" ) {
          Navigator.push(
            context!,
            MaterialPageRoute(builder: (context) => LeaveRequestScreen()),
          );
          } else if (title == "Danh sách đơn" ) {
          Navigator.push(
            context!,
            MaterialPageRoute(builder: (context) => MyLeaveRequestsScreen()),
          );
          } else if (title == "Thông báo" ) {
          Navigator.push(
            context!,
            MaterialPageRoute(builder: (context) => NotificationsScreen()),
          );
          } else if (title == "Thông tin" ) {   
          Navigator.push(
            context!,
            MaterialPageRoute(builder: (context) => AboutScreen()),
          );
          } else if (title == "Nhân viên" ) {
          Navigator.push(
            context!,
            MaterialPageRoute(builder: (context) => EmployeesScreen()),
          );
          } else if (title == "Cài đặt" ) {
        }
      },
      child: Card(
        color: Colors.white.withOpacity(0.95),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: iconColor),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}