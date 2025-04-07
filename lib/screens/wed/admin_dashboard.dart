// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hr_app_ver2/screens/admin/admin_employees_screen.dart';
import 'package:hr_app_ver2/screens/admin/delete_employee.dart';
import 'package:hr_app_ver2/screens/admin/admin_salary_screen.dart';
import 'package:hr_app_ver2/services/salary_calculator.dart';
import 'package:hr_app_ver2/screens/admin/admin_leave_management_screen.dart';

enum AdminScreen {
  dashboard,
  employees,
  reports,
  deleteList,
  salary,
  leaveManagement,
  // Bỏ notifications
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  AdminScreen _selectedScreen = AdminScreen.dashboard;
  bool _isCalculating = false;
  bool _isLoadingScreen = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0.2, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final Map<AdminScreen, Widget> _screens = {
    AdminScreen.dashboard: Center(
      child: Text(
        "Trang Tổng Quan",
        style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    ),
    AdminScreen.employees: AdminEmployeesScreen(),
    AdminScreen.reports: Center(
      child: Text(
        "Báo Cáo",
        style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    ),
    AdminScreen.deleteList: DeleteEmployee(),
    AdminScreen.salary: AdminSalaryScreen(),
    AdminScreen.leaveManagement: AdminLeaveManagementScreen(),
    // Bỏ AdminNotificationsScreen
  };

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

  Future<void> _calculateSalaries() async {
    final months = _getMonthOptions();
    String? selectedMonth;

    selectedMonth = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Chọn tháng để tính lương", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (context, setState) => DropdownButton<String>(
            value: selectedMonth ?? months.first,
            items: months.map((month) {
              return DropdownMenuItem<String>(
                value: month,
                child: Text(month, style: GoogleFonts.poppins()),
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
            child: Text("Hủy", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedMonth ?? months.first),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Chọn", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (selectedMonth == null) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Bạn có chắc muốn tính lương cho tháng $selectedMonth?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Hủy", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Tính", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isCalculating = true;
    });

    try {
      await SalaryCalculator.calculateSalariesForMonth(month: selectedMonth!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã tính lương cho tháng $selectedMonth", style: GoogleFonts.poppins())),
      );
    } catch (e) {
      String errorMessage = "Lỗi khi tính lương: $e";
      if (e.toString().contains("The query requires an index")) {
        errorMessage = "Truy vấn yêu cầu chỉ mục. Vui lòng tạo chỉ mục trong Firestore và thử lại.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage, style: GoogleFonts.poppins())),
      );
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  Future<void> _logout() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận đăng xuất", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Bạn có chắc muốn đăng xuất?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Hủy", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Đăng xuất", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã đăng xuất thành công", style: GoogleFonts.poppins())),
      );
    }
  }

  void _onScreenChange(AdminScreen screen) async {
    setState(() {
      _isLoadingScreen = true;
    });
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {
      _selectedScreen = screen;
      _isLoadingScreen = false;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3F51B5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2, offset: Offset(2, 2)),
              ],
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
                    borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "Admin Panel",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 1))],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildMenuItem(Icons.dashboard, "Trang tổng quan", AdminScreen.dashboard),
                _buildMenuItem(Icons.people, "Nhân viên", AdminScreen.employees),
                _buildMenuItem(Icons.bar_chart, "Báo cáo", AdminScreen.reports),
                _buildMenuItem(Icons.delete, "Danh sách xóa", AdminScreen.deleteList),
                _buildMenuItem(Icons.account_balance_wallet, "Bảng lương", AdminScreen.salary),
                _buildMenuItem(Icons.request_page, "Danh sách đơn nghỉ", AdminScreen.leaveManagement),
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
                    onTap: _isCalculating ? null : _calculateSalaries,
                  ),
                ),
                Spacer(),
                Divider(color: Colors.white24),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.white70),
                  title: Text("Đăng xuất", style: GoogleFonts.poppins(color: Colors.white70)),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[100]!, Colors.grey[200]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _isLoadingScreen
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                        strokeWidth: 3,
                      ),
                    )
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: _screens[_selectedScreen]!,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, AdminScreen screen) {
    bool isSelected = _selectedScreen == screen;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)]
              : [],
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.lightBlueAccent : Colors.white70,
            size: 28,
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.lightBlueAccent : Colors.white70,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          onTap: () => _onScreenChange(screen),
          hoverColor: Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }
}