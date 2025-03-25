import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String userName = "";
  String userEmail = "";

  final List<Widget> _screens = [
    HomeScreen(),
    EmployeesScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('employees').doc(user.uid).get();
      setState(() {
        userName = userDoc['name'] ?? "Tên nhân viên";
        userEmail = userDoc['email'] ?? "email@example.com";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_circle, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(userName, style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text(userEmail, style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Trang chủ'),
              onTap: () => _changeScreen(0),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Hồ sơ cá nhân'),
              onTap: () => _changeScreen(3),
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Chấm công'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Bảng lương'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.event_note),
              title: Text('Đơn nghỉ phép'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Thông báo'),
              onTap: () => _changeScreen(2),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _screens[_currentIndex]),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CurvedNavigationBar(
              index: _currentIndex,
              height: 65.0,
              backgroundColor: Colors.transparent,
              color: Colors.blueAccent,
              buttonBackgroundColor: const Color(0xFFFFA726),
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 500),
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                Icon(Icons.home, size: 30, color: Colors.white),
                Icon(Icons.people, size: 30, color: Colors.white),
                Icon(Icons.notifications, size: 30, color: Colors.white),
                Icon(Icons.person, size: 30, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _changeScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.pop(context); // Đóng Drawer sau khi chọn mục
  }
}