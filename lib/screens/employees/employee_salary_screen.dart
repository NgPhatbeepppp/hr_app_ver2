// lib/screens/employee_salary_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart'; // Thêm animate_do

class EmployeeSalaryScreen extends StatefulWidget {
  @override
  _EmployeeSalaryScreenState createState() => _EmployeeSalaryScreenState();
}

class _EmployeeSalaryScreenState extends State<EmployeeSalaryScreen> {
  String? selectedMonth;
  List<String> availableMonths = [];
  Map<String, dynamic>? salaryData;
  final NumberFormat currencyFormat = NumberFormat("#,##0", "vi_VN");

  @override
  void initState() {
    super.initState();
    _loadAvailableMonths();
  }

  Future<void> _loadAvailableMonths() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('salaries')
        .where('userId', isEqualTo: userId)
        .get();

    final months = snapshot.docs.map((doc) => doc['month'] as String).toSet().toList();
    months.sort((a, b) => b.compareTo(a));

    setState(() {
      availableMonths = months;
      selectedMonth = months.isNotEmpty ? months.first : null;
      if (selectedMonth != null) _loadSalaryData(selectedMonth!);
    });
  }

  Future<void> _loadSalaryData(String month) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('salaries')
        .where('userId', isEqualTo: userId)
        .where('month', isEqualTo: month)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        salaryData = snapshot.docs.first.data();
      });
    } else {
      setState(() {
        salaryData = null;
      });
    }
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
                        "Lương của tôi",
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
              // Nội dung chính
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInUp(
                        duration: Duration(milliseconds: 1000),
                        child: Text(
                          "Chọn tháng:",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      FadeInUp(
                        duration: Duration(milliseconds: 1100),
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
                              _loadSalaryData(value!);
                            });
                          },
                          dropdownColor: Colors.white,
                          icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: salaryData == null
                              ? Center(
                                  key: ValueKey(0),
                                  child: FadeInUp(
                                    duration: Duration(milliseconds: 1200),
                                    child: Text(
                                      "Không có dữ liệu lương",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                )
                              : FadeInUp(
                                  duration: Duration(milliseconds: 1200),
                                  child: Card(
                                    key: ValueKey(1),
                                    elevation: 6,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    color: Colors.white.withOpacity(0.95),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.account_balance_wallet,
                                                color: Colors.green,
                                                size: 24,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "Tổng lương",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "${currencyFormat.format(salaryData!['salary'])} ₫",
                                            style: GoogleFonts.poppins(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          Divider(thickness: 1, height: 24, color: Colors.grey[300]),
                                          _buildSalaryDetailRow(
                                            icon: Icons.access_time,
                                            label: "Giờ làm việc:",
                                            value: "${salaryData!['totalHours']}h",
                                          ),
                                          SizedBox(height: 12),
                                          _buildSalaryDetailRow(
                                            icon: Icons.calendar_today,
                                            label: "Ngày tính:",
                                            value: DateFormat('dd/MM/yyyy').format(
                                              (salaryData!['calculatedAt'] as Timestamp).toDate(),
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          _buildSalaryDetailRow(
                                            icon: Icons.star,
                                            label: "Thưởng:",
                                            value: "${currencyFormat.format(salaryData!['bonus'] ?? 0)} ₫",
                                            valueColor: Colors.blueAccent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: valueColor ?? Colors.black54,
          ),
        ),
      ],
    );
  }
}