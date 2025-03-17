import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
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
                  Text(
                    "Chào mừng bạn!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // ✅ Chỉnh màu chữ tối hơn
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
                      color: Colors.black87, // ✅ Đổi màu chữ tối hơn
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
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _buildFeatureCard(Icons.person, "Nhân viên"),
                        _buildFeatureCard(Icons.notifications, "Thông báo"),
                        _buildFeatureCard(Icons.calendar_today, "Lịch nghỉ"),
                        _buildFeatureCard(Icons.attach_money, "Bảng lương"),
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

  Widget _buildFeatureCard(IconData icon, String title) {
    return Card(
      color: Colors.white.withOpacity(0.95), // ✅ Làm thẻ rõ hơn
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.blueAccent),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // ✅ Chỉnh màu chữ tối hơn
            ),
          ),
        ],
      ),
    );
  }
}
