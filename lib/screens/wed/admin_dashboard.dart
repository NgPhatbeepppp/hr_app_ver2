import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hr_app_ver2/screens/admin/admin_employees_screen.dart';


class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text("Trang tổng quan", style: TextStyle(fontSize: 24))),
    AdminEmployeesScreen(),
    Center(child: Text("Báo cáo", style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ✅ Sidebar mềm mại hơn
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: Color(0xFF34495E), // Màu xanh đậm nhưng dịu hơn
              borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)), // ✅ Bo góc
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Header sidebar
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent], // ✅ Gradient nhẹ nhàng
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text("Admin Panel",
                          style: GoogleFonts.poppins(
                              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                // ✅ Menu items
                _buildMenuItem(Icons.dashboard, "Trang tổng quan", 0),
                _buildMenuItem(Icons.people, "Nhân viên", 1),
                _buildMenuItem(Icons.bar_chart, "Báo cáo", 2),
                Spacer(),
                Divider(color: Colors.white24),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.white70),
                  title: Text("Đăng xuất", style: GoogleFonts.poppins(color: Colors.white70)),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          ),

          // ✅ Nội dung chính
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[200], // Nền sáng nhẹ nhàng
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Widget tạo menu item
  Widget _buildMenuItem(IconData icon, String title, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: _selectedIndex == index ? Colors.white.withOpacity(0.1) : Colors.transparent, // ✅ Hiệu ứng chọn mềm mại
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: _selectedIndex == index ? Colors.lightBlueAccent : Colors.white70),
        title: Text(title,
            style: GoogleFonts.poppins(
                color: _selectedIndex == index ? Colors.lightBlueAccent : Colors.white70)),
        selected: _selectedIndex == index,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
