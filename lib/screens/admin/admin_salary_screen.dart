// lib/screens/admin/admin_salary_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border; // Thư viện để tạo file Excel
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:universal_html/html.dart' as html; // Dùng cho web

class AdminSalaryScreen extends StatefulWidget {
  @override
  _AdminSalaryScreenState createState() => _AdminSalaryScreenState();
}

class _AdminSalaryScreenState extends State<AdminSalaryScreen> {
  String? selectedMonth;
  List<String> availableMonths = [];
  int totalEmployees = 0;
  double totalSalary = 0.0;

  // Định dạng số tiền với dấu phẩy
  final NumberFormat currencyFormat = NumberFormat("#,##0", "vi_VN");

  @override
  void initState() {
    super.initState();
    _loadAvailableMonths();
  }

  // Lấy danh sách các tháng có dữ liệu lương từ Firestore
  Future<void> _loadAvailableMonths() async {
    final snapshot = await FirebaseFirestore.instance.collection('salaries').get();
    final months = snapshot.docs.map((doc) => doc['month'] as String).toSet().toList();
    months.sort((a, b) => b.compareTo(a)); // Sắp xếp giảm dần (mới nhất trước)
    setState(() {
      availableMonths = months;
      selectedMonth = months.isNotEmpty ? months.first : null;
    });
  }

  // Xuất dữ liệu ra Excel
  Future<void> _exportToExcel(List<Map<String, dynamic>> salaryData) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Tiêu đề cột
    sheet.cell(CellIndex.indexByString("A1")).value = "Tên nhân viên";
    sheet.cell(CellIndex.indexByString("B1")).value = "Lương (₫)";
    sheet.cell(CellIndex.indexByString("C1")).value = "Giờ làm việc";
    sheet.cell(CellIndex.indexByString("D1")).value = "Ngày tính";

    // Dữ liệu
    for (int i = 0; i < salaryData.length; i++) {
      var data = salaryData[i];
      sheet.cell(CellIndex.indexByString("A${i + 2}")).value = data['name'];
      sheet.cell(CellIndex.indexByString("B${i + 2}")).value = currencyFormat.format(data['salary']);
      sheet.cell(CellIndex.indexByString("C${i + 2}")).value = data['totalHours'].toString();
      sheet.cell(CellIndex.indexByString("D${i + 2}")).value = data['calculatedAt'];
    }

    // Lưu file và tải về (web)
    var fileBytes = excel.encode();
    final blob = html.Blob([fileBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "BangLuong_$selectedMonth.xlsx")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề và dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                  "Bảng Lương Nhân Viên",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedMonth,
                      hint: Text("Chọn tháng", style: GoogleFonts.poppins()),
                      items: availableMonths.map((month) {
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
                      underline: SizedBox(), // Ẩn gạch chân mặc định
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (selectedMonth == null) return;
                      final salarySnapshot = await FirebaseFirestore.instance
                          .collection('salaries')
                          .where('month', isEqualTo: selectedMonth)
                          .get();
                      List<Map<String, dynamic>> salaryData = [];
                      for (var doc in salarySnapshot.docs) {
                        String userId = doc['userId'];
                        var employeeDoc = await FirebaseFirestore.instance
                            .collection('employees')
                            .doc(userId)
                            .get();
                        salaryData.add({
                          'name': employeeDoc['name'] ?? "Không xác định",
                          'salary': doc['salary']?.toDouble() ?? 0.0,
                          'totalHours': doc['totalHours']?.toDouble() ?? 0.0,
                          'calculatedAt': DateFormat('dd/MM/yyyy').format(
                              (doc['calculatedAt'] as Timestamp).toDate()),
                        });
                      }
                      await _exportToExcel(salaryData);
                    },
                    icon: Icon(Icons.download),
                    label: Text("Xuất Excel", style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          // Thông tin tổng quan
          if (selectedMonth != null)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('salaries')
                  .where('month', isEqualTo: selectedMonth)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  totalEmployees = snapshot.data!.docs.length;
                  totalSalary = snapshot.data!.docs.fold(0.0, (sum, doc) {
                    return sum + (doc['salary']?.toDouble() ?? 0.0);
                  });
                }
                return Row(
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "Tổng nhân viên: $totalEmployees",
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "Tổng lương: ${currencyFormat.format(totalSalary)} ₫",
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          SizedBox(height: 16),
          // Bảng lương
          Expanded(
            child: selectedMonth == null
                ? Center(
                    child: Text(
                      "Vui lòng chọn tháng để xem bảng lương",
                      style: GoogleFonts.poppins(fontSize: 18),
                    ),
                  )
                : _buildSalaryTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('salaries').where('month', isEqualTo: selectedMonth).snapshots(),
      builder: (context, salarySnapshot) {
        if (salarySnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (salarySnapshot.hasError) {
          return Center(
            child: Text("Lỗi: ${salarySnapshot.error}", style: GoogleFonts.poppins()),
          );
        }
        if (!salarySnapshot.hasData || salarySnapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "Không có dữ liệu lương cho tháng $selectedMonth",
              style: GoogleFonts.poppins(fontSize: 18),
            ),
          );
        }

        var salaries = salarySnapshot.data!.docs;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: DataTable(
                columnSpacing: 48,
                headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueAccent.withOpacity(0.1)),
                dataRowColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.blueAccent.withOpacity(0.05); // Hiệu ứng hover
                  }
                  return null;
                }),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      "Tên nhân viên",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Lương",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Giờ làm việc",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Ngày tính",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
                rows: salaries.asMap().entries.map((entry) {
                  int index = entry.key;
                  var salaryDoc = entry.value;
                  String userId = salaryDoc['userId'];
                  double salary = salaryDoc['salary']?.toDouble() ?? 0.0;
                  double totalHours = salaryDoc['totalHours']?.toDouble() ?? 0.0;
                  Timestamp calculatedAt = salaryDoc['calculatedAt'];

                  return DataRow(
                    color: MaterialStateProperty.resolveWith((states) {
                      if (index % 2 == 0) {
                        return Colors.grey.shade50; // Màu nền xen kẽ
                      }
                      return Colors.white;
                    }),
                    cells: [
                      DataCell(
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('employees').doc(userId).get(),
                          builder: (context, employeeSnapshot) {
                            if (!employeeSnapshot.hasData) {
                              return Text("Đang tải...", style: GoogleFonts.poppins());
                            }
                            if (employeeSnapshot.hasError) {
                              return Text("Lỗi", style: GoogleFonts.poppins());
                            }
                            String name = employeeSnapshot.data!['name'] ?? "Không xác định";
                            return Text(name, style: GoogleFonts.poppins(fontSize: 14));
                          },
                        ),
                      ),
                      DataCell(
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${currencyFormat.format(salary)} ₫",
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.green),
                          ),
                        ),
                      ),
                      DataCell(
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            totalHours.toStringAsFixed(0),
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ),
                      DataCell(
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(calculatedAt.toDate()),
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}