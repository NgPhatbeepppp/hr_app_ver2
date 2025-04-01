import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hr_app_ver2/screens/admin/admin_employees_screen.dart';
import 'package:hr_app_ver2/screens/admin/delete_employee.dart';
import 'package:hr_app_ver2/screens/admin/admin_salary_screen.dart'; // Import bảng lương
import 'package:hr_app_ver2/services/salary_calculator.dart'; // Import hàm tính lương

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isCalculating = false;

  final List<Widget> _screens = [
    Center(child: Text("Trang tổng quan", style: TextStyle(fontSize: 24))),
    AdminEmployeesScreen(),
    Center(child: Text("Báo cáo", style: TextStyle(fontSize: 24))),
    DeleteEmployee(),
    AdminSalaryScreen(), // Thêm màn hình bảng lương
  ];

  // Tạo danh sách tháng để chọn (6 tháng gần nhất)
  List<String> _getMonthOptions() {
    List<String> months = [];
    final now = DateTime.now();
    for (int i = 0; i < 6; i++) {
      final monthDate = DateTime(now.year, now.month - i);
      String monthKey = "${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}";
      months.add(monthKey);
    }
    return months;
  }

  // Dialog chọn tháng và xác nhận
  Future<void> _calculateSalaries() async {
    final months = _getMonthOptions();
    String? selectedMonth;

    // Dialog chọn tháng
    selectedMonth = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Chọn tháng để tính lương"),
        content: StatefulBuilder(
          builder: (context, setState) => DropdownButton<String>(
            value: selectedMonth ?? months.first,
            items: months.map((month) {
              return DropdownMenuItem<String>(
                value: month,
                child: Text(month),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedMonth = value;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedMonth ?? months.first),
            child: Text("Chọn"),
          ),
        ],
      ),
    );

    if (selectedMonth == null) return;

    // Dialog xác nhận
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận"),
        content: Text("Bạn có chắc muốn tính lương cho tháng $selectedMonth?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Tính"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Thực hiện tính lương
    setState(() {
      _isCalculating = true;
    });

    try {
      await SalaryCalculator.calculateSalariesForMonth(month: selectedMonth!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã tính lương cho tháng $selectedMonth")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tính lương: $e")),
      );
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: Color(0xFF34495E),
              borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
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
                          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                _buildMenuItem(Icons.dashboard, "Trang tổng quan", 0),
                _buildMenuItem(Icons.people, "Nhân viên", 1),
                _buildMenuItem(Icons.bar_chart, "Báo cáo", 2),
                _buildMenuItem(Icons.delete, "Danh sách xóa", 3),
                _buildMenuItem(Icons.account_balance_wallet, "Bảng lương", 4), // Mục bảng lương
                AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: _isCalculating ? Colors.white.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.calculate, color: Colors.white70),
                    title: Text("Tính lương", style: GoogleFonts.poppins(color: Colors.white70)),
                    trailing: _isCalculating
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : null,
                    onTap: _isCalculating ? null : _calculateSalaries, // Gọi hàm tính lương
                  ),
                ),
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
          // Nội dung chính
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[200],
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: _selectedIndex == index ? Colors.white.withOpacity(0.1) : Colors.transparent,
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