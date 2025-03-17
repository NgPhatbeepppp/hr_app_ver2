import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/employees/employees_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                HomeScreen(), 
                EmployeesScreen(),
                NotificationsScreen(),
                ProfileScreen(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: CustomNavClipper(),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2)
                  ],
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white70,
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  elevation: 0, // Loại bỏ hiệu ứng nền chữ nhật khi nhấn vào icon
                  items: [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
                    BottomNavigationBarItem(icon: Icon(Icons.people), label: "Nhân viên"),
                    BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Thông báo"),
                    BottomNavigationBarItem(icon: Icon(Icons.person), label: "Hồ sơ"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double curveHeight = 25;

    Path path = Path();
    path.moveTo(0, curveHeight);
    path.quadraticBezierTo(size.width / 4, 0, size.width / 2, 0);
    path.quadraticBezierTo(size.width * 3 / 4, 0, size.width, curveHeight);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}